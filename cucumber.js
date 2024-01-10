const common = [
  "features/**/*.feature",
  "--require-module ts-node/register", // typescript cucumber
  "--require ./features/**/step_definitions/**/*.ts",
  `--format-options '{"snippetInterface": "synchronous"}'`,
  "--parallel 5",
].join(" ");

module.exports = {
  default: common,
};
