import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione limitata ai primi {int}",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementProducers(
      { limit, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.responseOffsetOne = await apiClient.agreements.getAgreementProducers(
      { limit: 50, offset },
      getAuthorizationHeader(this.token)
    );

    this.responseOffsetTwo = await apiClient.agreements.getAgreementProducers(
      { limit: 50, offset: offset + 1 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementProducers(
      { q: encodeURIComponent(keyword), limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} erogator(i)(e)",
  async function (statusCode: number, consumers: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });

    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, consumers);
  }
);

Then(
  "si ottiene status code 200 con la corretta verifica dell'offset",
  async function () {
    assertContextSchema(this, {
      responseOffsetOne: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(
            z.object({
              id: z.string(),
            })
          ),
        }),
      }),
      responseOffsetTwo: z.object({
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

    assert.equal(this.responseOffsetOne.status, 200);
    assert.equal(this.responseOffsetTwo.status, 200);

    // due response (operazioni di listing) di cui: la prima ha offset 0, la seconda ha offset - 1
    // il secondo elemento della seconda lista è uguale al primo elemento della prima
    assert.equal(
      this.responseOffsetOne.data.results[0].id,
      this.responseOffsetTwo.data.results[1].id
    );
  }
);
