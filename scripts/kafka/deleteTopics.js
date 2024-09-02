import { Kafka } from 'kafkajs';
import { generateAuthToken } from "aws-msk-iam-sasl-signer-js";

const quietModeOn = typeof process.env.QUIET_MODE != 'undefined' && process.env.QUIET_MODE == '1';


async function oauthBearerTokenProvider(region) {
   // Uses AWS Default Credentials Provider Chain to fetch credentials
   const authTokenResponse = await generateAuthToken({ region });
   return {
       value: authTokenResponse.token
   }
}

const run = async () => {
    let admin = null;
    try {

        if (!process.env.DOMAIN_TOPIC_PREFIX && !process.env.DEBEZIUM_OFFSETS_TOPIC) {
            console.error(`Env vars DOMAIN_TOPIC_PREFIX and DEBEZIUM_OFFSETS_TOPIC cannot be both null.`);
            throw new Error(`Env vars DOMAIN_TOPIC_PREFIX and DEBEZIUM_OFFSETS_TOPIC cannot be both null.`);
        }

        let sanitizedPrefix = [];
        let sanitizedExactMatch = [];

        if (process.env.DOMAIN_TOPIC_PREFIX) {
            sanitizedPrefix.push(process.env.DOMAIN_TOPIC_PREFIX);
        }
        if (process.env.DEBEZIUM_OFFSETS_TOPIC) {
            sanitizedExactMatch.push(process.env.DEBEZIUM_OFFSETS_TOPIC);
        }
        logInfo("Setup Kafka connection.");
        const kafka = new Kafka({
            clientId: 'kafka-scripts',
            brokers: process.env.KAFKA_BROKERS.split(","),
            ssl: true,
            sasl: {
                mechanism: 'oauthbearer',
                oauthBearerProvider: () => oauthBearerTokenProvider(process.env.AWS_REGION)
            }
        });

        logInfo("Connect to Kafka with admin client.");
        admin = kafka.admin();
        await admin.connect();
        
        logInfo("List Kafka existing topics.");
        const kafkaTopics = await admin.listTopics();

        if (kafkaTopics && kafkaTopics.length) {
            let topicsToDelete = [];

            kafkaTopics.forEach( topic => {
                let pushed = false;
                if (sanitizedPrefix.length) {
                    if (sanitizedPrefix.some(sp => topic.startsWith(sp))) {
                        topicsToDelete.push(topic);
                        pushed = true;
                    }
                }
                if (!pushed && sanitizedExactMatch.length) {
                    if (sanitizedExactMatch.some(sp => topic === sp)) {
                        topicsToDelete.push(topic);
                        pushed = true;
                    }
                }
            });
            
            if (topicsToDelete.length) {
                logInfo(`Deleting ${topicsToDelete}`);
                await admin.deleteTopics({
                    topics: topicsToDelete
                });
            }
        } else {
            logInfo("No topic found, skipping deletion.");
        }
    } catch (ex) {
        console.error(ex);
        throw ex;
    } finally {
        if (admin) {
            logInfo("Disconnect Kafka admin client.")
            await admin.disconnect();
        }
    }
}

const logInfo = (message) => {
    if (!quietModeOn) {
        console.log(message);
    }
}

run();
