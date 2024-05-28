import dotenv from "dotenv";
import { TypeOf, z } from "zod";

dotenv.config({ override: true });

const Env = z.object({
  BFF_BASE_URL: z.string(),
  ENVIRONMENT: z.string(),
  REMOTE_WELLKNOWN_URL: z.string(),
  SESSION_TOKENS_DURATION_SECONDS: z.coerce.number(),
  TENANTS_IDS_FILE_PATH: z.string(),
  ST_VERBOSE_MODE: z.string().optional(),
  MAX_POLLING_TRIES: z.coerce.number(),
  POLLING_SLEEP_TIME: z.coerce.number(),
  CUCUMBER_OPTS_PARALLEL: z.coerce.number(),
});

const parsedEnv = Env.safeParse(process.env);

// TODO: rimuovere quando sarà disponibile ambiente QA
const isDryRun = process.env.DRY_RUN === "true";

if (!parsedEnv.success && !isDryRun) {
  const invalidEnvVars = parsedEnv.error.issues.flatMap((issue) => issue.path);
  console.error("Invalid or missing env vars: " + invalidEnvVars.join(", "));
  process.exit(1);
}

declare global {
  namespace NodeJS {
    interface ProcessEnv extends TypeOf<typeof Env> {}
  }
}
