import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRiskAnalysis,
  getToken,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import { Role, TenantType } from "../../common-steps";

Given(
  "un {string} di {string} ha già aggiunto un'analisi del rischio a quell'e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, role);
    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        token,
        this.eserviceId,
        getRiskAnalysis({ completed: true, tenantType })
      );
  }
);

When(
  "l'utente aggiorna l'analisi del rischio di quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
      tenantType: TenantType,
    });

    this.response = await apiClient.eservices.updateEServiceRiskAnalysis(
      this.eserviceId,
      this.riskAnalysisId,
      getRiskAnalysis({ completed: false, tenantType: this.tenantType }),
      getAuthorizationHeader(this.token)
    );
  }
);
