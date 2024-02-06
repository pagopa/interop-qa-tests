import assert from "assert";
import {
  Before,
  Given,
  Then,
  BeforeAll,
  setDefaultTimeout,
} from "@cucumber/cucumber";
import { z } from "zod";
import { generateSessionTokens } from "../../../utils/session-tokens";
import { env } from "../../../configs/env";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { assertContextSchema, getRandomInt } from "./../../../utils/commons";

// Increase duration of every step with the following timeout (Default is 5000 milliseconds)
setDefaultTimeout(5 * 60 * 1000);

const Party = z.enum(["GSP", "PA1", "PA2", "Privato"]);
export type Party = z.infer<typeof Party>;
const Role = z.enum(["admin", "api", "security", "support", "api,security"]);
export type Role = z.infer<typeof Role>;

export const SessionTokens = z.record(Party, z.record(Role, z.string()));
export type SessionTokens = z.infer<typeof SessionTokens>;

BeforeAll(async function () {
  this.parameters.tokens = SessionTokens.parse(
    await generateSessionTokens(env.TENANT_IDS_FILE_PATH)
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
    this.token = this.tokens[party]![role]!;
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} e-services",
  function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, count);
  }
);

Given(
  "un {string} di {string} ha già creato un e-service con un descrittore in stato {string}",
  async function (
    role: Role,
    party: Party,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;

    this.eserviceId = await dataPreparationService.createEService(token);

    const { descriptorId } =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
      });

    this.descriptorId = descriptorId;
  }
);

Given(
  "un {string} di {string} ha già creato un e-service con un descrittore in stato {string} e un documento già caricato",
  async function (
    role: Role,
    party: Party,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;

    this.eserviceId = await dataPreparationService.createEService(token);

    const { descriptorId, documentId } =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
        withDocument: true,
      });
    this.descriptorId = descriptorId;
    this.documentId = documentId;
  }
);

Then("si ottiene status code {int}", function (statusCode: number) {
  assertContextSchema(this, {
    response: z.object({
      status: z.number(),
    }),
  });
  assert.equal(this.response.status, statusCode);
});
