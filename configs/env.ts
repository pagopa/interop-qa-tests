import dotenv from "dotenv";
import { z } from "zod";

dotenv.config();

const Env = z.object({
  BFF_BASE_URL: z.string(),
  ENVIRONMENT: z.string(),
  REMOTE_WELLKNOWN_URL: z.string(),
  SESSION_TOKENS_DURATION_SECONDS: z.coerce.number(),
  TENANT_IDS_FILE_PATH: z.string(),
  ST_VERBOSE_MODE: z.string().optional(),
});

const parsedEnv = Env.safeParse(process.env);

if (!parsedEnv.success) {
  const invalidEnvVars = parsedEnv.error.issues.flatMap((issue) => issue.path);
  throw new Error("Invalid or missing env vars: " + invalidEnvVars.join(", "));
}

export const env = parsedEnv.data;
