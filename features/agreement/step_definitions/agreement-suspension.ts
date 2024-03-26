import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

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
