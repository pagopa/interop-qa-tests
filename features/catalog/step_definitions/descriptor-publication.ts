import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRiskAnalysis,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceDescriptorState, EServiceMode } from "../../../api/models";
import { Party, Role } from "./common-steps";

Given(
  "l'utente ha già caricato un'interfaccia per quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    await dataPreparationService.addInterfaceToDescriptor(
      this.token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

Given(
  "un {string} di {string} ha già creato un e-service in modalità {string} con un descrittore in stato {string}",
  async function (
    role: Role,
    party: Party,
    mode: EServiceMode,
    descriptorState: EServiceDescriptorState
  ) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;

    this.eserviceId = await dataPreparationService.createEService(token, {
      mode,
    });

    // If descriptorState is not DRAFT we have to add a completed risk analysis in order to correctly publish the descriptor
    if (mode === "RECEIVE" && descriptorState !== "DRAFT") {
      await dataPreparationService.addRiskAnalysisToEService(
        this.token,
        this.eserviceId,
        getRiskAnalysis({ completed: true })
      );
    }

    this.descriptorId =
      await dataPreparationService.createDescriptorWithGivenState(
        token,
        this.eserviceId,
        descriptorState
      );
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
    });

    await dataPreparationService.addRiskAnalysisToEService(
      this.token,
      this.eserviceId,
      getRiskAnalysis({ completed: false })
    );
  }
);
