import assert from "assert";
import { Given, When, Then, setDefaultTimeout } from "@cucumber/cucumber";
import { API_ROOT_URL } from "./tokens";

setDefaultTimeout(30 * 1000);

function packEservice(name: string, token: string) {
  return {
    method: "POST",
    headers: {
      Authorization: "Bearer " + token,
      "X-Correlation-Id": "abc",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      name,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    }),
  };
}

export function optionsForGetRoute(token: string) {
  return {
    method: "GET",
    headers: {
      Authorization: "Bearer " + token,
      "X-Correlation-Id": "abc",
      "Content-Type": "application/json",
    },
  };
}

async function sleep(time: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, time);
  });
}

export async function polling(path: string, options: object) {
  for (let i = 0; i < 4; i++) {
    const result = await fetch(`${API_ROOT_URL}/${path}`, options);
    if (result.status !== 404) {
      return result;
    }
    await sleep(Math.min(1000 * 2 ** i, 30 * 1000));
  }
  throw Error("Eventual consistency error");
}

export async function createEservice(
  token: string,
  { givenEserviceName = null, withPolling = false }: {givenEserviceName?: null | string, withPolling?: boolean}
) {
  const eserviceName = givenEserviceName || `e-service-${Math.random()}`;
  const postEService = packEservice(eserviceName, token);
  const response = await fetch(`${API_ROOT_URL}/eservices`, postEService);
  const eserviceId = ((await response.json()) as { id: string }).id;
  if (withPolling) {
    await polling(
      `producers/eservices/${eserviceId}`,
      optionsForGetRoute(token)
    );
  }
  return { eserviceName, response, eserviceId };
}

When("l'utente crea un e-service con lo stesso nome", async function (this: { token: string, eserviceName: string | null, response: unknown }) {
  const { response } = await createEservice(this.token, {
    givenEserviceName: this.eserviceName,
    withPolling: false,
  });
  this.response = response;
});

Given("l'utente ha già creato un e-service", async function (this: { token: string, eserviceName: string, response: unknown, eserviceId: string }) {
  const { eserviceName, response, eserviceId } = await createEservice(this.token, {
    withPolling: true,
  });
  this.eserviceName = eserviceName;
  this.response = response;
  this.eserviceId = eserviceId
});

When("l'utente crea un e-service", async function (this: { token: string, eserviceName: string, response: unknown }) {
  const { eserviceName, response } = await createEservice(this.token, {});
  this.eserviceName = eserviceName;
  this.response = response;
});

Then("la creazione restituisce errore - {string}", function (this: {response: { status: number } }, statusCode: string) {
  assert.equal(this.response.status, Number(statusCode));
});

Then("si ottiene status code {string}", function (this: {response: { status: number } }, statusCode: string) {
  assert.equal(this.response.status, Number(statusCode));
});

