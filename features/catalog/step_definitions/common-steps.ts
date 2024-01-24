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
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { assertContextSchema, getRandomInt } from "./../../../utils/commons";

// Increase duration of every step with the following timeout (Default is 5000 milliseconds)
setDefaultTimeout(5 * 60 * 1000);

const Party = z.enum(["GSP", "PA1", "PA2", "Privato"]);
export type Party = z.infer<typeof Party>;
const Role = z.enum(["admin", "api", "security"]);
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

    if (descriptorState === "ARCHIVED" || descriptorState === "DEPRECATED") {
      throw new Error(
        "ARCHIVED and DEPRECATED state not supported by this Given"
      );
    }

    const token = this.tokens[party]![role]!;

    // 1. Create e-service
    const eserviceId = await dataPreparationService.createEService(token);

    // 2. Create DRAFT descriptor
    const descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      eserviceId
    );

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;

    if (descriptorState === "DRAFT") {
      return;
    }

    // 3. Add interface to descriptor
    await dataPreparationService.addInterfaceToDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    // 4. Publish Descriptor
    await dataPreparationService.publishDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    if (descriptorState === "PUBLISHED") {
      return;
    }

    // 5. Suspend Descriptor
    await dataPreparationService.suspendDescriptor(
      token,
      eserviceId,
      descriptorId
    );
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
