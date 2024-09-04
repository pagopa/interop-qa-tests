import "dotenv/config";

export const parallel = {
  parallel: Number(process.env.CUCUMBER_OPTS_PARALLEL),
};
export const format = {
  format: ["progress-bar"],
  formatOptions: { snippetInterface: "synchronous" },
};
export const base = {
  ...parallel,
  ...format,
};

export const validate = {
  dryRun: true,
};

export const node = {
  requireModule: ["ts-node/register"],
};

export const all = {
  paths: ["features/**/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const catalog = {
  paths: ["features/catalog/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const attribute = {
  paths: ["features/attribute/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const agreement = {
  paths: ["features/agreement/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const purpose = {
  paths: ["features/purpose/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const authorization = {
  paths: ["features/authorization/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const tenant = {
  paths: ["features/tenant/*.feature"],
  require: [
    "./features/**/step_definitions/**/*.ts",
    "./features/common-steps.ts",
  ],
};

export const onlyReady = {
  tags: "(not @wait_for_fix) and (not @resource_intensive) and (not @wait_for_clarification) and (not @fixed_in_node)",
};

export default {};
