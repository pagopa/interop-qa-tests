import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede la cancellazione della richiesta di aggiornamento della stima di carico",
  async function () {
    assertContextSchema(this, {
      purposeId: z.string(),
      versionId: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.purposes.deletePurposeVersion(
      this.purposeId,
      this.versionId,
      getAuthorizationHeader(this.token)
    );
  }
);
