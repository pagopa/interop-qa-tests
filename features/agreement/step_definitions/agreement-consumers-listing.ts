import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing dei fruitori dei propri e-service limitata ai primi {int}",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementConsumers(
      { limit, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori dei propri e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementConsumers(
      { limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori dei propri e-service con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.responseOffsetOne = await apiClient.agreements.getAgreementConsumers(
      { limit: 50, offset },
      getAuthorizationHeader(this.token)
    );

    this.responseOffsetTwo = await apiClient.agreements.getAgreementConsumers(
      { limit: 50, offset: offset + 1 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori dei propri e-service filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementConsumers(
      { q: encodeURIComponent(keyword), limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} fruitor(i)(e)",
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

When(
  "l'utente richiede una operazione di listing degli erogatori dei propri e-service limitata ai primi {int}",
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
  "l'utente richiede una operazione di listing degli erogatori dei propri e-service con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementProducers(
      { limit: 50, offset },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori dei propri e-service filtrando per la keyword {string}",
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

    assert.equal(
      this.responseOffsetOne.data.results[1].id,
      this.responseOffsetTwo.data.results[0].id
    );
  }
);
