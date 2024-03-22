import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import {
  UpdateEServiceDescriptorQuotas,
  UpdateEServiceDescriptorSeed,
} from "../../../api/models";
import { ESERVICE_DAILY_CALLS } from "../../../services/data-preparation.service";

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
      dailyCallsPerConsumer: ESERVICE_DAILY_CALLS.perConsumer,
      dailyCallsTotal: ESERVICE_DAILY_CALLS.total * 2,
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

When(
  "l'utente aggiorna la durata del voucher e le soglie di carico di quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const seed: UpdateEServiceDescriptorQuotas = {
      voucherLifespan: 60,
      dailyCallsPerConsumer: ESERVICE_DAILY_CALLS.perConsumer,
      dailyCallsTotal: ESERVICE_DAILY_CALLS.total * 2,
    };
    this.response = await apiClient.eservices.updateDescriptor(
      this.eserviceId,
      this.descriptorId,
      seed,
      getAuthorizationHeader(this.token)
    );
  }
);
