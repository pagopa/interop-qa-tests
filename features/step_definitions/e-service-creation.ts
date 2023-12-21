import assert from "assert";
import { Given, When, Then, setDefaultTimeout } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  makePolling,
  assertContextSchema,
} from "../../utils/commons";
import { apiClient } from "../../api";

setDefaultTimeout(30 * 1000);

export async function createEservice(
  token: string,
  {
    givenEserviceName = null,
    withPolling = false,
  }: { givenEserviceName?: null | string; withPolling?: boolean }
) {
  const eserviceName = givenEserviceName || `e-service-${Math.random()}`;
  const response = await apiClient.eservices.createEService(
    {
      name: eserviceName,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(token)
  );

  const eserviceId = response.data.id;

  if (withPolling) {
    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDetails(
          eserviceId,
          getAuthorizationHeader(token)
        ),
      (res) => res.status !== 404
    );
  }
  return { eserviceName, response, eserviceId };
}

When("l'utente crea un e-service con lo stesso nome", async function () {
  assertContextSchema(this, {
    token: z.string(),
  });

  const { response } = await createEservice(this.token, {
    givenEserviceName: this.eserviceName,
    withPolling: false,
  });
  this.response = response;
});

Given("l'utente ha già creato un e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
  });

  const { eserviceName, response, eserviceId } = await createEservice(
    this.token,
    {
      withPolling: true,
    }
  );
  this.eserviceName = eserviceName;
  this.response = response;
  this.eserviceId = eserviceId;
});

When("l'utente crea un e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
  });

  const { eserviceName, response } = await createEservice(this.token, {});
  this.eserviceName = eserviceName;
  this.response = response;
});

Then("si ottiene status code {string}", function (statusCode: string) {
  assertContextSchema(this, {
    response: z.object({
      status: z.number(),
    }),
  });
  assert.equal(this.response.status, Number(statusCode));
});
