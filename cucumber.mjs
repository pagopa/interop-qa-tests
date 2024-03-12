const common = {
  paths: ["features/**/*.feature"],
  require: ["./features/**/step_definitions/**/*.ts"],
  parallel: Number(process.env.CUCUMBER_OPTS_PARALLEL) || 1,
};
const format = {
  format: ["progress-bar"],
  formatOptions: { snippetInterface: "synchronous" },
};

export default {
  ...common,
  ...format,
  requireModule: ["ts-node/register"],
};

export const bun = {
  ...common,
  ...format,
};
