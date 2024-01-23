import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceDescriptorState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "l'utente ha già creato una versione in {string} per quell'eservice",
  async function (descriptorState: EServiceDescriptorState) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    const descriptorId = await dataPreparationService.createDraftDescriptor(
      this.token,
      this.eserviceId
    );

    this.descriptorId = descriptorId;

    if (descriptorState === "DRAFT") {
      return;
    }

    // 3. Add interface to descriptor
    await dataPreparationService.addInterfaceToDescriptor(
      this.token,
      this.eserviceId,
      descriptorId
    );

    // 4. Publish Descriptor
    await dataPreparationService.publishDescriptor(
      this.token,
      this.eserviceId,
      descriptorId
    );

    if (descriptorState === "PUBLISHED") {
      return;
    }

    // 5. Suspend Descriptor
    if (descriptorState === "SUSPENDED") {
      await dataPreparationService.suspendDescriptor(
        this.token,
        this.eserviceId,
        descriptorId
      );
      return;
    }

    if (descriptorState === "ARCHIVED" || descriptorState === "DEPRECATED") {
      if (descriptorState === "DEPRECATED") {
        // Optional. Create an agreement

        const agreementId = await dataPreparationService.createAgreement(
          this.token,
          this.eserviceId,
          this.descriptorId
        );

        await dataPreparationService.submitAgreement(this.token, agreementId);
      }

      // Create another DRAFT descriptor
      const secondDescriptorId =
        await dataPreparationService.createDraftDescriptor(
          this.token,
          this.eserviceId
        );

      this.secondDescriptorId = secondDescriptorId;

      // Add interface to secondDescriptor
      await dataPreparationService.addInterfaceToDescriptor(
        this.token,
        this.eserviceId,
        this.secondDescriptorId
      );

      // Publish secondDescriptor
      await dataPreparationService.publishDescriptor(
        this.token,
        this.eserviceId,
        this.secondDescriptorId
      );

      // Check until the first descriptor is in desired state
      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            this.eserviceId,
            this.descriptorId,
            getAuthorizationHeader(this.token)
          ),
        (res) => res.data.state === descriptorState
      );
    }
  }
);

When("l'utente clona quell'e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });
  this.response = await apiClient.eservices.cloneEServiceByDescriptor(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );
});
