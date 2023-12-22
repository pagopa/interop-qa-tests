import assert from "assert";
import { Given, When, Then, setDefaultTimeout } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  getRandomInt,
  makePolling,
  assertContextSchema,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { assertValidResponse } from "./e-service-catalog-listing";

setDefaultTimeout(5 * 60 * 1000);

When("l'utente crea un e-service con lo stesso nome", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceName: z.string(),
  });
  this.response = await apiClient.eservices.createEService(
    {
      name: this.eserviceName,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(this.token)
  );
});

Given("l'utente ha già creato un e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
  });
  const eserviceName = `e-service-${getRandomInt()}`;
  const response = await apiClient.eservices.createEService(
    {
      name: eserviceName,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(this.token)
  );
  const eserviceId = response.data.id;
  assertValidResponse(response);

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDetails(
        eserviceId,
        getAuthorizationHeader(this.token)
      ),
    (res) => res.status !== 404
  );

  this.eserviceName = eserviceName;
  this.response = response;
  this.eserviceId = eserviceId;
});

When("l'utente crea un e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
  });
  const eserviceName = `e-service-${getRandomInt()}`;
  const response = await apiClient.eservices.createEService(
    {
      name: eserviceName,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(this.token)
  );
  this.eserviceName = eserviceName;
  this.response = response;
});

Then(
  "la creazione restituisce errore - {string}",
  function (statusCode: string) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
      }),
    });
    assert.equal(this.response.status, Number(statusCode));
  }
);

Then("si ottiene status code {string}", function (statusCode: string) {
  assertContextSchema(this, {
    response: z.object({
      status: z.number(),
    }),
  });
  assert.equal(this.response.status, Number(statusCode));
});
