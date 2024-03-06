import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di rifiuto di quella richiesta di fruizione con messaggio",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      agreementId: z.string(),
    });

    this.response = await apiClient.agreements.rejectAgreement(
      this.agreementId,
      {
        reason: "rejection reason: qa-testing",
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di rifiuto di quella richiesta di fruizione senza messaggio",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      agreementId: z.string(),
    });

    this.response = await apiClient.agreements.rejectAgreement(
      this.agreementId,
      {
        reason: "",
      },
      getAuthorizationHeader(this.token)
    );
  }
);
