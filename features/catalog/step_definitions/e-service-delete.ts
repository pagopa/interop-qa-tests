import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../../utils/commons";

Given(
  "{string} ha già creato un e-service con un descrittore in DRAFT",
  async function (tenantType: TenantType) {
    const token = await getToken(tenantType);

    const { eserviceId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(token);

    this.eserviceId = eserviceId;
  }
);

When("l'utente cancella quell'e-service", async function () {
  assertContextSchema(this, { token: z.string(), eserviceId: z.string() });
  this.response = await apiClient.eservices.deleteEService(
    this.eserviceId,
    getAuthorizationHeader(this.token)
  );
});
