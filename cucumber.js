const commands = [
  "features/**/*.feature",
  "--require ./features/**/step_definitions/**/*.ts",
  `--format-options '{"snippetInterface": "synchronous"}'`,
  "--format progress-bar",
  "--parallel 5",
];

// If we are running in a bun environment, we don't need to require ts-node since bun already does that
if (!process.isBun) {
  commands.push("--require-module ts-node/register");
}

module.exports = {
  default: commands.join(" "),
};
