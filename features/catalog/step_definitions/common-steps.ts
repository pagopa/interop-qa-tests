import assert from "assert";
import { Before, Given, Then } from "@cucumber/cucumber";
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

Then(
  "si ottiene status code {int} e la lista di {int} risultati",
  function (statusCode: number, count: number) {
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.pagination.totalCount, count);
  }
);

Before(function (scenario) {
  console.log(`\n\n${scenario.pickle.name}\n`);
});
