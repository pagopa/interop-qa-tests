import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { UpdateEServiceDescriptorSeed } from "../../../api/models";

When(
  "l'utente aggiorna alcuni parametri di quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const seed: UpdateEServiceDescriptorSeed = {
      description: "Questo è un e-service di test",
      audience: ["api/v1"],
      voucherLifespan: 60,
      dailyCallsPerConsumer: 10,
      dailyCallsTotal: 200, // changed
      agreementApprovalPolicy: "AUTOMATIC",
      attributes: {
        certified: [],
        declared: [],
        verified: [],
      },
    };
    this.response = await apiClient.eservices.updateDraftDescriptor(
      this.eserviceId,
      this.descriptorId,
      seed,
      getAuthorizationHeader(this.token)
    );
  }
);
