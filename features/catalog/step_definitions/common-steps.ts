import assert from "assert";
import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType, Role } from "../../common-steps";
import { assertContextSchema, getToken } from "./../../../utils/commons";

Then(
  "si ottiene status code {int} e la lista di {int} e-service(s)",
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
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this);

    const token = getToken(this.tokens, tenantType, role);

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
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this);

    const token = getToken(this.tokens, tenantType, role);

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
