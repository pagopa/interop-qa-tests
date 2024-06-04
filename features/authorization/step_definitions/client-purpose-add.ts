import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede l'associazione della finalità al client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
      purposeId: z.string(),
    });

    this.response = await apiClient.clients.addClientPurpose(
      this.clientId,
      {
        purposeId: this.purposeId,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
