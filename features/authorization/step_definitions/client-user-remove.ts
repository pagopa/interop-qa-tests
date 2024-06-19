import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede la rimozione di quel membro dal client",
  async function () {
    assertContextSchema(this, {
      clientId: z.string(),
      clientMemberUserId: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.clients.removeUserFromClient(
      this.clientId,
      this.clientMemberUserId,
      getAuthorizationHeader(this.token)
    );
  }
);
