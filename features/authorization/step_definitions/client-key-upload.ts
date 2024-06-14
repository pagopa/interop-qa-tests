import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  createBase64PublicKey,
  getAuthorizationHeader,
  getRandomInt,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede il caricamento di una chiave pubblica di tipo {string}",
  async function (keyType: "RSA" | "NON-RSA") {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
    });

    const key = createBase64PublicKey(keyType);

    this.response = await apiClient.clients.createKeys(
      this.clientId,
      [
        {
          use: "SIG",
          alg: "RS256",
          name: `key-${this.TEST_SEED}-${getRandomInt()}`,
          key,
        },
      ],
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede il caricamento di una chiave pubblica di tipo {string} di lunghezza {int}",
  async function (keyType: "RSA" | "NON-RSA", keyLength: number) {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
    });

    this.response = await apiClient.clients.createKeys(
      this.clientId,
      [
        {
          use: "SIG",
          alg: "RS256",
          name: `key-${this.TEST_SEED}-${getRandomInt()}`,
          key: createBase64PublicKey(keyType, keyLength),
        },
      ],
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede il caricamento di una chiave pubblica di tipo {string} di lunghezza {int} senza i delimitatori di inizio e fine",
  async function (keyType: "RSA" | "NON-RSA", keyLength: number) {
    assertContextSchema(this, {
      token: z.string(),
      clientId: z.string(),
    });

    const key = createBase64PublicKey(keyType, keyLength, false);

    this.response = await apiClient.clients.createKeys(
      this.clientId,
      [
        {
          use: "SIG",
          alg: "RS256",
          name: `key-${this.TEST_SEED}-${getRandomInt()}`,
          key,
        },
      ],
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede il caricamento di una chiave pubblica di tipo {string} di lunghezza {int} con lo stesso kid",
  async function (_keyType: string, _keyLength: number) {
    assertContextSchema(this, {
      key: z.string(),
      token: z.string(),
      clientId: z.string(),
    });

    this.response = await apiClient.clients.createKeys(
      this.clientId,
      [
        {
          use: "SIG",
          alg: "RS256",
          name: `key-${this.TEST_SEED}-${getRandomInt()}`,
          key: this.key,
        },
      ],
      getAuthorizationHeader(this.token)
    );
  }
);
