import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { EServiceMode } from "../../../api/models";
import { apiClient } from "../../../api";
import { TenantType } from "../../../utils/commons";

Given(
  "{string} ha già creato un e-service in modalità {string} con un descrittore in DRAFT",
  async function (tenantType: TenantType, mode: EServiceMode) {
    assertContextSchema(this, { token: z.string() });

    const token = await getToken(tenantType);

    const { eserviceId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(token, {
        mode,
      });
    this.eserviceId = eserviceId;
  }
);

When("l'utente aggiunge un'analisi del rischio", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    tenantType: TenantType,
  });
  this.response = await apiClient.eservices.addRiskAnalysisToEService(
    this.eserviceId,
    await dataPreparationService.getRiskAnalysis({
      completed: true,
      tenantType: this.tenantType,
    }),
    getAuthorizationHeader(this.token)
  );
});

When(
  "l'utente aggiunge un'analisi del rischio non corretta per la tipologia di ente",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    // We want to get the wrong risk analysis template, so we need to invert the tenantType
    const tenantType =
      this.tenantType === "GSP" || this.tenantType === "Privato"
        ? "PA1"
        : "Privato";

    this.response = await apiClient.eservices.addRiskAnalysisToEService(
      this.eserviceId,
      await dataPreparationService.getRiskAnalysis({
        completed: true,
        tenantType,
      }),
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente aggiunge un'analisi del rischio con versione template non aggiornata",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    const { name, riskAnalysisForm } =
      await dataPreparationService.getRiskAnalysis({
        completed: true,
        tenantType: this.tenantType,
      });

    const outdatedVersion = (Number(riskAnalysisForm.version) - 1).toFixed(1);

    this.response = await apiClient.eservices.addRiskAnalysisToEService(
      this.eserviceId,
      {
        name,
        riskAnalysisForm: {
          ...riskAnalysisForm,
          version: outdatedVersion,
        },
      },
      getAuthorizationHeader(this.token)
    );
  }
);
