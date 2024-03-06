import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di archiviazione della richiesta di fruizione",
  async function () {
    assertContextSchema(this, { token: z.string(), agreementId: z.string() });
    this.response = await apiClient.agreements.archiveAgreement(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );
  }
);
