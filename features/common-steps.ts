import { setDefaultTimeout, Before, Given } from "@cucumber/cucumber";
import { z } from "zod";
import { getRandomInt, getToken } from "../utils/commons";

// Increase duration of every step with the following timeout (Default is 5000 milliseconds)
setDefaultTimeout(5 * 60 * 1000);

export const TenantType = z.enum(["GSP", "PA1", "PA2", "Privato"]);
export type TenantType = z.infer<typeof TenantType>;
export const Role = z.enum([
  "admin",
  "api",
  "security",
  "support",
  "api,security",
]);
export type Role = z.infer<typeof Role>;

export const SessionTokens = z.record(TenantType, z.record(Role, z.string()));
export type SessionTokens = z.infer<typeof SessionTokens>;

Before(function () {
  this.TEST_SEED = getRandomInt();
});

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, tenantType: TenantType) {
    this.token = await getToken(tenantType, role);
    this.role = role;
    this.tenantType = tenantType;
  }
);
