import assert from "assert";
import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType } from "../../../utils/commons";
import { assertContextSchema, getToken } from "../../../utils/commons";

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
  "{string} ha già creato un e-service con un descrittore in stato {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState
  ) {
    const token = await getToken(tenantType);

    // this.eserviceId = await dataPreparationService.deprecated__createEService(token);
    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(token);
    // const { descriptorId } =
    //   await dataPreparationService.deprecated__createDescriptorWithGivenState({
    //     token,
    //     eserviceId: this.eserviceId,
    //     descriptorState,
    //   });
    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId,
      descriptorId,
      descriptorState,
    });

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);

Given(
  "{string} ha già creato un e-service con un descrittore in stato {string} e un documento già caricato",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState
  ) {
    const token = await getToken(tenantType);

    // this.eserviceId = await dataPreparationService.deprecated__createEService(token);
    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(token);
    // const { descriptorId, documentId } =
    //   await dataPreparationService.deprecated__createDescriptorWithGivenState({
    //     token,
    //     eserviceId: this.eserviceId,
    //     descriptorState,
    //     withDocument: true,
    //   });
    const { documentId } =
      await dataPreparationService.bringDescriptorToGivenState({
        token,
        eserviceId,
        descriptorId,
        descriptorState,
        withDocument: true,
      });
    this.descriptorId = descriptorId;
    this.documentId = documentId;
  }
);
