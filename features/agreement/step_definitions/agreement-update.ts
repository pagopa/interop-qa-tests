import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di aggiornamento di quella richiesta di fruizione con messaggio",
  async function () {
    assertContextSchema(this, { agreementId: z.string(), token: z.string() });
    this.response = await apiClient.agreements.updateAgreement(
      this.agreementId,
      { consumerNotes: "consumer note updated - QA" },
      getAuthorizationHeader(this.token)
    );
  }
);
