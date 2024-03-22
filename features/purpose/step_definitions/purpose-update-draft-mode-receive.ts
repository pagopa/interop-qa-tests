import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  getAuthorizationHeader,
  assertContextSchema,
  getRiskAnalysis,
  getToken,
} from "../../../utils/commons";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";
import { Role, TenantType } from "../../common-steps";

Given(
  "un {string} di {string} ha già creato un'analisi del rischio datata per quell'e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);

    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        token,
        this.eserviceId,
        {
          riskAnalysisForm: {
            ...getRiskAnalysis({ completed: true, tenantType })
              .riskAnalysisForm,
            version: "1.0",
          },
          name: "test QA purpose",
        }
      );
  }
);

When(
  "l'utente aggiorna quella finalità per quell'e-service in erogazione inversa",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });

    this.response = await apiClient.reverse.updateReversePurpose(
      this.purposeId,
      {
        title: "some new title",
        description: "some new description",
        isFreeOfCharge: true,
        freeOfChargeReason: "some new free of charge reason",
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
