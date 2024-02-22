const common = [
  "features/**/*.feature",
  "--require-module ts-node/register", // typescript cucumber
  "--require ./features/**/step_definitions/**/*.ts",
  `--format-options '{"snippetInterface": "synchronous"}'`,
  "--format progress-bar",
  "--parallel 5",
].join(" ");

module.exports = {
  default: common,
};
