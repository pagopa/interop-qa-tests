import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing degli erogatori",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getProducers(
      { limit: 20, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori con limit {int}",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getProducers(
      { limit, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.offset = offset;
    this.response = await apiClient.producers.getProducers(
      { limit: 20, offset },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori filtrando per nome aderente {string}",
  async function (nomeAderente: string) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getProducers(
      { limit: 20, offset: 0, q: nomeAderente },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e il giusto numero di erogatori in base all'offset richiesto",
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
    const response = await apiClient.producers.getProducers(
      { limit: 20, offset: 0 },
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(response);

    const totalCount = response.data.pagination.totalCount;

    assert.equal(this.response.status, 200);
    assert.equal(this.response.data.results.length, totalCount - this.offset);
  }
);
