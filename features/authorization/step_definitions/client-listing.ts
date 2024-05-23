import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  Role,
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  getUserId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { ClientKind } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già creato {int} client {string} con la keyword {string} nel nome",
  async function (
    tenantType: TenantType,
    numClient: number,
    cliendKind: ClientKind,
    keyword: string
  ) {
    assertContextSchema(this);
    const token = await getToken(tenantType);

    const arr = new Array(numClient).fill(0);

    const result = await Promise.all(
      arr.map((_, i) =>
        dataPreparationService.createClient(token, cliendKind, {
          name: `client-${i}-${this.TEST_SEED}-${keyword}`,
        })
      )
    );

    this.clientId = result[0];
  }
);

When(
  "l'utente richiede una operazione di listing dei client con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.clients.getClients(
      {
        limit: 12,
        offset,
        q: "123456789",
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  'l\'utente richiede una operazione di listing dei client con filtro "CONSUMER"',
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.clients.getClients(
      {
        limit: 12,
        offset: 0,
        kind: "CONSUMER",
        q: this.TEST_SEED,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei client filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.clients.getClients(
      {
        limit: 12,
        offset: 0,
        q: `${this.TEST_SEED}-${keyword}`,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei client filtrando per membro utente con ruolo {string}",
  async function (roleOfMember: Role) {
    assertContextSchema(this, {
      token: z.string(),
    });

    const userIdMember = getUserId(this.tenantType, roleOfMember);

    this.response = await apiClient.clients.getClients(
      {
        limit: 12,
        offset: 0,
        userIds: [userIdMember],
        q: this.TEST_SEED,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.clients.getClients(
      {
        limit: 12,
        offset: 0,
        q: this.TEST_SEED,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei client limitata a {int} risultati",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.clients.getClients(
      {
        limit,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
