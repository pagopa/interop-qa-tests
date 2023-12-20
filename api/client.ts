import { env } from "../configs/env";
import { Api } from "./models";

export const apiClient = new Api({
  baseURL: env.BFF_BASE_URL,
  headers: {
    "X-Correlation-Id": "test",
  },
  // Make axios accept all response statuses without throwing errors
  validateStatus: () => true,
});
