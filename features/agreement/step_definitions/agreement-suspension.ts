import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { TenantType } from "../../common-steps";
import { apiClient } from "../../../api";

Given(
  "{string} ha già attivato quella richiesta di fruizione",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });
    const token = getToken(this.tokens, tenant, "admin");
    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);

When(
  "l'utente richiede una operazione di sospensione di quella richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    this.response = await apiClient.agreements.suspendAgreement(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );
  }
);
