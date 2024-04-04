import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  assertContextSchema,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";

When(
  "l'utente crea una versione in bozza per quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    this.response = await apiClient.eservices.createDescriptor(
      this.eserviceId,
      {
        description: "Questo è un e-service di test",
        audience: ["api/v1"],
        voucherLifespan: 60,
        dailyCallsPerConsumer: ESERVICE_DAILY_CALLS.perConsumer,
        dailyCallsTotal: ESERVICE_DAILY_CALLS.total,
        agreementApprovalPolicy: "AUTOMATIC",
        attributes: {
          certified: [],
          declared: [],
          verified: [],
        },
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "l'utente ha già creato una versione in bozza per quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    this.descriptorId = await dataPreparationService.createDraftDescriptor(
      this.token,
      this.eserviceId
    );
  }
);
