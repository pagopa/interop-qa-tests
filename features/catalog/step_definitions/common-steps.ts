import { Before, Given } from "@cucumber/cucumber";
import { generateSessionTokens } from "../../../utils/session-tokens";
import { getRandomInt } from "./../../../utils/commons";

export type Party = "GSP" | "PA1" | "Privato";
export type Role = "admin" | "api,security";

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, party: Party) {
    this.TEST_SEED = getRandomInt();
    const tokens = await generateSessionTokens(
      process.env.TENANT_IDS_FILE_PATH
    );
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    this.token = tokens[party][role];
    // TO DO IMPROVE
    this.tokens = tokens;
  }
);

Before(function (scenario) {
  console.log(`\n\n${scenario.pickle.name}\n`);
});
