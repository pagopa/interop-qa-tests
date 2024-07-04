
const namePropertyKey = "name";

export function getTopicDefaultConfiguration() {
    return [
        { name: "cleanup.policy", value: "delete" }, 
        { name: "retention.ms", value: "-1" }, 
        { name: "compression.type", value: "producer" }
    ];
}
    
function getTopicOptions() {
    return [{
        targetLabel: "numPartitions",
        expectedLabel: "partitions",
        required: true
    },{
        targetLabel: "replicationFactor",
        expectedLabel: "replication.factor",
        required: true
    }];
}
 
export function getTopicRequiredOptions() {
    return getTopicOptions().filter(option => option.required);
}
 
export function isTopicNameProperty(propKey) {
    return propKey === namePropertyKey;
}

export function isTopicOption(optionKey) {
    return getTopicOptions().map(opt => opt.expectedLabel).indexOf(optionKey) >= 0;
}
 
export function isTopicRequiredOption(optionKey) {
    return getTopicRequiredOptions().map(opt => opt.expectedLabel).indexOf(optionKey) >= 0;
}
 
export function getTopicRequiredOptionKey(optionKey) {
    return getTopicRequiredOptions().find(ro => ro.expectedLabel == optionKey).targetLabel;
}
 
export function isTopicDefaultConfig(configKey) {
    let defaultTopicConfiguration = getTopicDefaultConfiguration();

    return defaultTopicConfiguration.findIndex(ce => ce.name === configKey) >= 0;
}
