/* eslint-disable @typescript-eslint/explicit-member-accessibility */
import * as kafkaConfigUtility from "./kafkaConfigs.js";

export class KafkaTopic {
  #topicConfig = {
    topic: null,
    configEntries: kafkaConfigUtility.getTopicDefaultConfiguration(),
  };

  getTopicName() {
    return structuredClone(this.#topicConfig.topic);
  }

  getTopicOptions() {
    const keys = Object.keys(this.#topicConfig);
    const opts = {};

    for (const k of keys) {
      if (k !== "topic" && k !== "configEntries") {
        opts[k] = this.#topicConfig[k];
      }
    }

    return structuredClone(opts);
  }

  getTopicOption(optionName) {
    let val = null;
    if (this.#topicConfig[optionName]) {
      val = structuredClone(this.#topicConfig[optionName]);
    }

    return val;
  }

  getTopicConfigurations() {
    return structuredClone(this.#topicConfig.configEntries);
  }

  getTopicConfiguration(configName) {
    return structuredClone(
      this.#topicConfig.configEntries.filter((ce) => ce.name === configName)
    );
  }

  getTopic() {
    return structuredClone(this.#topicConfig);
  }

  setTopicConfig(configName, configValue) {
    if (kafkaConfigUtility.isTopicNameProperty(configName)) {
      this.#topicConfig.topic = configValue;
    } else if (kafkaConfigUtility.isTopicRequiredOption(configName)) {
      const optionToOverride =
        kafkaConfigUtility.getTopicRequiredOptionKey(configName);
      if (optionToOverride) {
        this.#topicConfig[optionToOverride] = configValue;
      }
    } else {
      let overrideIndex = -1;
      if (kafkaConfigUtility.isTopicDefaultConfig(configName)) {
        overrideIndex = this.#topicConfig.configEntries.findIndex(
          (ce) => ce.name === configName
        );
      }

      if (overrideIndex !== -1) {
        this.#topicConfig.configEntries[overrideIndex].value = configValue;
      } else {
        this.#topicConfig.configEntries.push({
          name: configName,
          value: configValue,
        });
      }
    }
  }

  isValidTopicConfiguration() {
    const topicConfig = this.#topicConfig;

    if (!topicConfig.topic) {
      return {
        valid: false,
        error: `Topic name cannot be null`,
      };
    }

    const requiredOptions = kafkaConfigUtility.getTopicRequiredOptions();
    for (const requiredOption of requiredOptions) {
      if (
        typeof topicConfig[requiredOption.targetLabel] == "undefined" ||
        topicConfig[requiredOption.targetLabel] == null
      ) {
        return {
          valid: false,
          error: `Topic configuration is missing required option ${requiredOption.expectedLabel}`,
        };
      }
    }

    return {
      valid: true,
      error: null,
    };
  }
}
