import assert from "assert";
import { Before, Given, Then, BeforeAll } from "@cucumber/cucumber";
import { z } from "zod";
import { generateSessionTokens } from "../../../utils/session-tokens";
import { assertContextSchema, getRandomInt } from "./../../../utils/commons";

const Party = z.enum(["GSP", "ComuneDiMilano", "AgID", "Privato"]);
export type Party = z.infer<typeof Party>;
const Role = z.enum(["admin"]);
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
  console.log(`\n\n${scenario.pickle.name}\n`);
});

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, party: Party) {
    this.token = this.parameters.tokens[party]![role]!;
    this.tokens = this.parameters.tokens;
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} e-services",
  function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          pagination: z.object({
            totalCount: z.number(),
          }),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.pagination.totalCount, count);
  }
);
