import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRiskAnalysis,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { ESERVICE_DAILY_CALLS } from "../../../services/data-preparation.service";

When(
  "l'utente aggiorna quella finalità per quell'e-service in erogazione diretta",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });
    this.response = await apiClient.purposes.updatePurpose(
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

When(
  "l'utente aggiorna quella finalità per quell'e-service in erogazione diretta con una riskAnalysis in versione diversa da quella attualmente pubblicata",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });
    const riskAnalysisForm = getRiskAnalysis({
      tenantType: this.tenantType,
      completed: true,
    }).riskAnalysisForm;
    // TODO
    // TMP: check if this is correct!
    riskAnalysisForm.version = "4.0";
    this.response = await apiClient.purposes.updatePurpose(
      this.purposeId,
      {
        title: "some new title",
        description: "some new description",
        isFreeOfCharge: true,
        freeOfChargeReason: "some new free of charge reason",
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
        riskAnalysisForm,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
