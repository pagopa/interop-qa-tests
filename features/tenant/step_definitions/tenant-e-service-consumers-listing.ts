import assert from "assert";
import { When, Then } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing dei fruitori",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.consumers.getConsumers(
      { limit: 20, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e la lista di aderenti contenente {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(
            z.object({
              id: z.string(),
            })
          ),
        }),
      }),
    });

    const organizationId = getOrganizationId(tenantType);

    assert.equal(this.response.status, 200);
    assert.ok(
      this.response.data.results.some(
        (consumer) => consumer.id === organizationId
      ),
      `${tenantType} non è presente nella lista dei fruitori`
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori con limit {int}",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.consumers.getConsumers(
      { limit, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} aderent(i)(e)",
  async function (statusCode: number, tenantNum: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });

    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, tenantNum);
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.offset = offset;
    this.response = await apiClient.consumers.getConsumers(
      { limit: 20, offset },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e il giusto numero di fruitori in base all'offset richiesto",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    const response = await apiClient.consumers.getConsumers(
      { limit: 20, offset: 0 },
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(response);

    const totalCount = response.data.pagination.totalCount;

    assert.equal(this.response.status, 200);
    assert.equal(this.response.data.results.length, totalCount - this.offset);
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori filtrando per nome aderente {string}",
  async function (nomeAderente: string) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.consumers.getConsumers(
      { limit: 20, offset: 0, q: nomeAderente },
      getAuthorizationHeader(this.token)
    );
  }
);
