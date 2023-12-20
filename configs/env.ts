import dotenv from "dotenv";

dotenv.config();

const BFF_BASE_URL = process.env.BFF_BASE_URL;

if (!BFF_BASE_URL) {
  throw new Error("BFF_BASE_URL is not defined");
}

export const env = {
  BFF_BASE_URL,
} as const;
