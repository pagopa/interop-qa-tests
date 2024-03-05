import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When("l'utente inoltra quella richiesta di fruizione", async function () {
  assertContextSchema(this, {
    token: z.string(),
    agreementId: z.string(),
  });
  this.response = await apiClient.agreements.submitAgreement(
    this.agreementId,
    {},
    getAuthorizationHeader(this.token)
  );
});
