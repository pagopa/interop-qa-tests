import kafkajs from 'kafkajs';
const { ConfigResourceTypes, Kafka, logLevel } = kafkajs;
import { generateAuthToken } from "aws-msk-iam-sasl-signer-js";
import { readFileSync, readdirSync } from "fs";
import path from 'path';
import { shouldIgnoreLine, parsePropsLine } from "./utils/propertiesParser.js";
import { KafkaTopic }  from "./utils/kafkaTopic.js";

const quietModeOn = typeof process.env.QUIET_MODE != 'undefined' && process.env.QUIET_MODE == '1';
const logInfo = (message) => {
    if (!quietModeOn) {
        console.log(`${message}`);
    }
}

async function oauthBearerTokenProvider(region) {
   // Uses AWS Default Credentials Provider Chain to fetch credentials
   const authTokenResponse = await generateAuthToken({ region });
   return {
       value: authTokenResponse.token
   }
}

function buildJsonFromPropertiesFile (filePath) {
    let topicConfigurationContent = readFileSync(filePath).toString().split("\n");
    let propsToJson = {}
    
    if (!topicConfigurationContent.length) {
        return propsToJson;
    }
    
    for (let topicConfigurationContentEntry of topicConfigurationContent) {
        //Allow comments in props file but skip parsing
        if (shouldIgnoreLine(topicConfigurationContentEntry)) {
            continue;
        }
        
        let currentLineParsed = parsePropsLine(topicConfigurationContentEntry);
        if (!currentLineParsed["key"] || !currentLineParsed["value"]) {
            throw new Error(`Cannot parse key/value pair for line ${topicConfigurationContentEntry}`);
        }
        
        propsToJson[currentLineParsed["key"].toLowerCase()] = currentLineParsed["value"];
    }

    return propsToJson;
}


function buildTopicsConfig(topicsConfigurationPath) {
    let configurationsFound = readdirSync(topicsConfigurationPath);
    let outputConfigurations = [];
    
    for(let topicConfigurationFile of configurationsFound) {
        let topicConfigurationJson = buildJsonFromPropertiesFile(path.join(topicsConfigurationPath, topicConfigurationFile));
        
        let topicConfigObj = new KafkaTopic();
        if (topicConfigurationJson && Object.keys(topicConfigurationJson).length) {
            
            for (let configurationKey of Object.keys(topicConfigurationJson)) {
                topicConfigObj.setTopicConfig(configurationKey, topicConfigurationJson[configurationKey]);
            }
            
            const validationResult = topicConfigObj.isValidTopicConfiguration();            
            if (!validationResult.valid) {
                throw new Error(validationResult.error);
            }
            
            outputConfigurations.push(topicConfigObj);
        }
    }
    
    return outputConfigurations;
}

const run = async () => {
    if (!process.env.TOPICS_PROPERTIES_PATH) {
        throw new Error(`Missing TOPICS_PROPERTIES_PATH environment variable.`);
    }
    
    logInfo("Setup Kafka connection.");
    const kafka = new Kafka({
        clientId: 'kafka-scripts',
        brokers: [process.env.KAFKA_BROKERS],
        logLevel: logLevel.NOTHING,
        ssl: true,
        sasl: {
            mechanism: 'oauthbearer',
            oauthBearerProvider: () => oauthBearerTokenProvider(process.env.AWS_REGION)
        }
    });

    logInfo("Connect to Kafka with admin client.");
    const admin = kafka.admin();
    try {
        await admin.connect();
    } catch (ex) {
        throw new Error(`Cannot connect to Kafka with admin client.`);
    }

    const topicsConfigurationPath = process.env.TOPICS_PROPERTIES_PATH;
    const topicConfigurations = buildTopicsConfig(topicsConfigurationPath);
    let escalateDiff = false;
    let errors = [];
    
    try {
        for(let topicConfiguration of topicConfigurations) {
            logInfo(`Create topic ${topicConfiguration.getTopicName()}`);// with options:\n${JSON.stringify(topicConfiguration.getTopicOptions())} \nand configuration:\n${JSON.stringify(topicConfiguration.getTopicConfigurations())}\n`);
            let result = await admin.createTopics({
                validateOnly: false,
                waitForLeaders: false,
                topics: [topicConfiguration.getTopic()]
            });

            if (!result) { // result == false => implies cannot create topic
                let remoteConfigs = await admin.describeConfigs({
                    includeSynonyms: false,
                    resources: [{
                        type: ConfigResourceTypes.TOPIC,
                        name: topicConfiguration.getTopicName(),
                        configNames: topicConfiguration.getTopicConfigurations().map(entry => entry.name)
                    }]
                });
                
                // Get properties configuration for current topic 
                if (remoteConfigs && remoteConfigs.resources.length) {
                    remoteConfigs = remoteConfigs.resources[0].configEntries;
                }

                // Check diff between remote topic configuration and provided topic configuration
                let configDiffFound = [];
                topicConfiguration.getTopicConfigurations().forEach(localConfig => {
                    let remoteConfig = remoteConfigs.find(c => c.configName == localConfig.name);
                    if (remoteConfig && remoteConfig.configValue != localConfig.value) {
                        configDiffFound.push({
                            name: localConfig.name,
                            localValue: localConfig.value,
                            remoteValue: remoteConfig.configValue
                        });
                    }
                });

                if (configDiffFound.length) {
                    escalateDiff = true;
                    let mismatches = configDiffFound.map(cd => `{${cd.name}: remote value ${cd.remoteValue}, local value ${cd.localValue}}`);
                    let errorMsg = `Topic ${topicConfiguration.getTopicName()} already exists, following properties do not match:\n${mismatches}\n`
                    errors.push({
                        type: "TOPIC_CREATION_ERROR",
                        message: errorMsg
                    })
                    // Errore (topic esiste e properties non matchano)
                    //Do not print library error message - console.error(errorMsg);
                } else {
                    // Info (topic esiste e properties matchano)
                    logInfo(`Topic ${topicConfiguration.getTopicName()} already exists, all the specified properties match with remote ones.`);
                }
            }
        }

        if (escalateDiff) {
            throw new Error(`${errors.map(anError => `\n[${anError.type ? anError.type : "GENERIC_ERROR" }: ${anError.message}]`)}`);
        }
    } catch (ex) {
        let invalidConfiguration = ex.errors ? ex.errors.filter(e => e.type == "INVALID_CONFIG") : [];
        if (invalidConfiguration.length) {
            throw new Error(`[TOPIC INVALID CONFIGURATION] Found invalid configuration for ${invalidConfiguration.map(ic => ic.topic)}`);
        } else {
            throw ex;
        }
    } finally {
        if (admin) {
            logInfo("Disconnect Kafka admin client.");
            await admin.disconnect();
        }
    }
}

run();
