import assert from "assert";
import { Before, Given, Then, BeforeAll } from "@cucumber/cucumber";
import { z } from "zod";
import { generateSessionTokens } from "../../../utils/session-tokens";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRandomInt,
  makePolling,
} from "./../../../utils/commons";

const Party = z.enum(["GSP", "PA1", "PA2", "Privato"]);
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

export async function masterDescriptor(
  token: string,
  eserviceId: string,
  descriptorState: EServiceDescriptorState
) {
  // 2. Create DRAFT descriptor
  const descriptorId = await dataPreparationService.createDraftDescriptor(
    token,
    eserviceId
  );

  if (descriptorState === "DRAFT") {
    return descriptorId;
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
    return descriptorId;
  }

  // 5. Suspend Descriptor
  if (descriptorState === "SUSPENDED") {
    await dataPreparationService.suspendDescriptor(
      token,
      eserviceId,
      descriptorId
    );
    return descriptorId;
  }

  if (descriptorState === "ARCHIVED" || descriptorState === "DEPRECATED") {
    if (descriptorState === "DEPRECATED") {
      // Optional. Create an agreement

      const agreementId = await dataPreparationService.createAgreement(
        token,
        eserviceId,
        descriptorId
      );

      await dataPreparationService.submitAgreement(token, agreementId);
    }

    // Create another DRAFT descriptor
    const secondDescriptorId =
      await dataPreparationService.createDraftDescriptor(token, eserviceId);

    // Add interface to secondDescriptor
    await dataPreparationService.addInterfaceToDescriptor(
      token,
      eserviceId,
      secondDescriptorId
    );

    // Publish secondDescriptor
    await dataPreparationService.publishDescriptor(
      token,
      eserviceId,
      secondDescriptorId
    );

    // Check until the first descriptor is in desired state
    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === descriptorState
    );

    return descriptorId;
  }
}

Given(
  "un {string} di {string} ha già creato un e-service con un descrittore in stato {string}",
  async function (
    role: Role,
    party: Party,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;

    // 1. Create e-service
    this.eserviceId = await dataPreparationService.createEService(token);

    this.descriptorId = await masterDescriptor(
      token,
      this.eserviceId,
      descriptorState
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
