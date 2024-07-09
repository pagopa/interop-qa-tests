import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import { ClientKind, ClientSeed } from "../../../api/models";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRandomInt,
} from "../../../utils/commons";

When(
  "l'utente richiede la creazione di un client {string}",
  async function (clientKind: ClientKind) {
    assertContextSchema(this, {
      token: z.string(),
    });
    const clientSeed: ClientSeed = {
      name: `client ${getRandomInt()}`,
      description: "Descrizione client",
      members: [],
    };
    this.response =
      clientKind === "CONSUMER"
        ? await apiClient.clientsConsumer.createConsumerClient(
            clientSeed,
            getAuthorizationHeader(this.token)
          )
        : await apiClient.clientsApi.createApiClient(
            clientSeed,
            getAuthorizationHeader(this.token)
          );
  }
);
