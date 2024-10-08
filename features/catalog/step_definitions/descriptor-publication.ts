import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceDescriptorState, EServiceMode } from "../../../api/models";
import { TenantType } from "../../../utils/commons";

Given(
  "{string} ha già caricato un'interfaccia per quel descrittore",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.addInterfaceToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

Given(
  "{string} ha già creato un e-service in modalità {string} con un descrittore in stato {string}",
  async function (
    tenantType: TenantType,
    mode: EServiceMode,
    descriptorState: EServiceDescriptorState
  ) {
    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(token, {
        mode,
      });

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;

    // If descriptorState is not DRAFT we have to add a completed risk analysis in order to correctly publish the descriptor
    if (mode === "RECEIVE" && descriptorState !== "DRAFT") {
      this.riskAnalysisId =
        await dataPreparationService.addRiskAnalysisToEService(
          token,
          this.eserviceId,
          await dataPreparationService.getRiskAnalysis({
            completed: true,
            tenantType: this.tenantType,
          })
        );
    }

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId,
      descriptorId,
      descriptorState,
    });
  }
);

When("l'utente pubblica quel descrittore", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });

  this.response = await apiClient.eservices.publishDescriptor(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );
});

Given(
  "l'utente ha compilato parzialmente l'analisi del rischio",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    await dataPreparationService.addRiskAnalysisToEService(
      this.token,
      this.eserviceId,
      await dataPreparationService.getRiskAnalysis({
        completed: false,
        tenantType: this.tenantType,
      })
    );
  }
);
