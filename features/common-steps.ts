import {
  setDefaultTimeout,
  BeforeAll,
  Before,
  Given,
} from "@cucumber/cucumber";
import { z } from "zod";
import { getRandomInt, getToken } from "../utils/commons";
import { generateSessionTokens } from "../utils/session-tokens";

// Increase duration of every step with the following timeout (Default is 5000 milliseconds)
setDefaultTimeout(5 * 60 * 1000);

export const Party = z.enum(["GSP", "PA1", "PA2", "Privato"]);
export type Party = z.infer<typeof Party>;
export const Role = z.enum([
  "admin",
  "api",
  "security",
  "support",
  "api,security",
]);
export type Role = z.infer<typeof Role>;

export const SessionTokens = z.record(Party, z.record(Role, z.string()));
export type SessionTokens = z.infer<typeof SessionTokens>;

BeforeAll(async function () {
  this.parameters.tokens = SessionTokens.parse(
    await generateSessionTokens(process.env.TENANT_IDS_FILE_PATH)
  );
});

Before(function (scenario) {
  this.TEST_SEED = getRandomInt();
  this.tokens = this.parameters.tokens;

  console.log(`\n\n${scenario.pickle.name}\n`);
});

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, party: Party) {
    this.token = getToken(this.tokens, party, role);
    this.role = role;
    this.party = party;
  }
);
