import { env } from "../configs/env";
import { Api } from "./models";

/** This function helps to serialize correctly arrays in url params  */
const serializeParams = (query: Record<string, string[] | string>) =>
  Object.entries(query)
    // This filter is needed to remove undefined and null values, it is needed
    // ONLY to avoid undefined/null to be passed as a query params value, falsy values
    // like 0 or '' are allowed
    .filter(([, value]) => value !== undefined && value !== null)
    .map(([key, value]) =>
      Array.isArray(value)
        ? `${key}=${encodeURIComponent(value.join(","))}`
        : `${key}=${encodeURIComponent(value)}`
    )
    .join("&");

export const apiClient = new Api({
  baseURL: env.BFF_BASE_URL,
  headers: {
    "X-Correlation-Id": "test",
  },
  // Make axios accept all response statuses without throwing errors
  validateStatus: () => true,
  paramsSerializer: { serialize: serializeParams },
});
