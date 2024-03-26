import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../common-steps";

When(
  "l'utente erogatore richiede una operazione di listing delle finalità limitata alle prime {int} finalità",
  async function (limit: number) {
    assertContextSchema(this, { token: z.string(), tenantType: TenantType });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        offset: 0,
        limit,
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} finalità",
  async function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, count);
  }
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità con offset {int}",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità sui propri e-service",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrata per fruitore {string}",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrata per il primo e-service",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità in stato {string}",
  async function () {}
);

Given(
  "un {string} di {string} ha già creato {int} finalità in stato {string} per quell'e-service contenente la keyword {string}",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword {string}",
  async function () {}
);