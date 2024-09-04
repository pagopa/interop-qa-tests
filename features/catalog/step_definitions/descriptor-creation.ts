import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  assertContextSchema,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given("l'utente ha già pubblicato quel descrittore", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });

  await dataPreparationService.bringDescriptorToGivenState({
    token: this.token,
    eserviceId: this.eserviceId,
    descriptorId: this.descriptorId,
    descriptorState: "PUBLISHED",
  });
});

When(
  "l'utente crea una versione in bozza per quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    this.response = await apiClient.eservices.createDescriptor(
      this.eserviceId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e il descrittore contiene i campi del precedente",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      descriptorId: z.string(),
      response: z.object({
        status: z.number(),
        data: z.object({
          id: z.string(),
        }),
      }),
    });

    const descriptor = (
      await apiClient.producers.getProducerEServiceDescriptor(
        this.eserviceId,
        this.descriptorId,
        getAuthorizationHeader(this.token)
      )
    ).data;

    const newDescriptorId = this.response.data.id;

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          this.eserviceId,
          newDescriptorId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.status !== 404
    );

    const newDescriptor = (
      await apiClient.producers.getProducerEServiceDescriptor(
        this.eserviceId,
        newDescriptorId,
        getAuthorizationHeader(this.token)
      )
    ).data;

    assert.equal(this.response.status, 200);
    assert.equal(descriptor.description, newDescriptor.description);
    assert.equal(descriptor.voucherLifespan, newDescriptor.voucherLifespan);
    assert.equal(
      descriptor.dailyCallsPerConsumer,
      newDescriptor.dailyCallsPerConsumer
    );
    assert.equal(descriptor.dailyCallsTotal, newDescriptor.dailyCallsTotal);
    assert.equal(
      descriptor.agreementApprovalPolicy,
      newDescriptor.agreementApprovalPolicy
    );
    assert.deepEqual(descriptor.attributes, newDescriptor.attributes);
  }
);
