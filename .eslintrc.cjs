module.exports = {
  extends: ["@pagopa/eslint-config/strong"],
  "env": {
    node: true
  },
  rules: {
    // Any project level custom rule
    "@typescript-eslint/switch-exhaustiveness-check": "error",
    "default-case": "off",
    "prefer-arrow/prefer-arrow-functions": "off",
    eqeqeq: ["error", "smart"],
    "@typescript-eslint/consistent-type-definitions": "off",
    "sort-keys": "off",
    "functional/prefer-readonly-type": "off",
    "@typescript-eslint/no-shadow": "off",
    "extra-rules/no-commented-out-code": "off",
    "sonarjs/no-duplicate-string": "off",
    "max-lines-per-function": "off",
    "@typescript-eslint/naming-convention": "off",
    "@typescript-eslint/no-use-before-define": "off",
    "functional/immutable-data": "off",
    "no-invalid-this": "off",
    "@typescript-eslint/explicit-function-return-type": "off",
    "functional/no-let": "off",
    "no-console": "off"
  },
  ignorePatterns: [
    ".eslintrc.cjs",
  ],
};
