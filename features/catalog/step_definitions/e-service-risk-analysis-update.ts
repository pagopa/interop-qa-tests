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
import { TenantType } from "../../common-steps";

Given(
  "{string} ha già aggiunto un'analisi del rischio a quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = await getToken(tenantType);
    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        token,
        this.eserviceId,
        await getRiskAnalysis({ completed: true, tenantType })
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
      await getRiskAnalysis({ completed: false, tenantType: this.tenantType }),
      getAuthorizationHeader(this.token)
    );
  }
);
