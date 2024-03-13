import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente clona quella richiesta di fruizione", async function () {
  assertContextSchema(this, {
    token: z.string(),
    agreementId: z.string(),
  });

  this.response = await apiClient.agreements.cloneAgreement(
    this.agreementId,
    getAuthorizationHeader(this.token)
  );
});
