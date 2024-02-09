import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import { Party } from "./common-steps";

Given(
  "{string} ha un agreement attivo con quell'e-service",
  async function (party: Party) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const token = this.tokens[party]!.admin!;
    const agreementId = await dataPreparationService.createAgreement(
      token,
      this.eserviceId,
      this.descriptorId
    );

    await dataPreparationService.submitAgreement(token, agreementId);
  }
);
When(
  "l'utente richiede una operazione di download dei fruitori di quell'e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });
    this.response = await apiClient.eservices.getEServiceConsumers(
      this.eserviceId,
      getAuthorizationHeader(this.token)
    );
  }
);
