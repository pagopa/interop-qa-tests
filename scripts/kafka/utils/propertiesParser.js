
import { isTopicOption } from "./kafkaConfigs.js";

export function normalizeQuotes(stringToSanitize) {
    let sanitized = stringToSanitize.replaceAll("\"", '');
    sanitized = sanitized.replaceAll("'", '');

    return sanitized;
}

export function sanitizePropsLine (propKey, propValue) {
    let sanitizedKey = normalizeQuotes(propKey);
    let sanitizedValue = normalizeQuotes(propValue);
    
    if (isTopicOption(sanitizedKey)) {
        sanitizedValue = JSON.parse(sanitizedValue);
    }

    return {
        key: sanitizedKey,
        value: sanitizedValue
    }
}
    
export function parsePropsLine (propsEntry) {
    let currentLine = propsEntry.split("=");
    if (currentLine.length != 2) {
        throw new Error(`Topic configuration file ${topicConfigurationFile} is not properly formatted.`);
    }

    return sanitizePropsLine(currentLine[0], currentLine[1]);
}

export function isCommentLine (line) {
    return line && (line.startsWith("#") || line.startsWith("/"));
}

export function shouldIgnoreLine (line) {
    return !line || isCommentLine(line);
}
