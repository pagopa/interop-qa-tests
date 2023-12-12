const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');
const { setDefaultTimeout } = require('@cucumber/cucumber');

setDefaultTimeout(10 * 1000);

const API_ROOT_URL = 'https://selfcare.dev.interop.pagopa.it/backend-for-frontend/0.0'

function packEservice(name, token) {
  return {
    method: 'POST',
    headers: {
      Authorization: 'Bearer ' + token,
      'X-Correlation-Id': 'abc',
      "Content-Type": 'application/json'
    },
    body: JSON.stringify({
      name,
      description: 'Questo è un e-service di test',
      technology: "REST",
      mode: "DELIVER"
    })
  }
}

function optinsForGetEServicesById(token) {
  return {
    method: 'GET',
    headers: {
      Authorization: 'Bearer ' + token,
      'X-Correlation-Id': 'abc',
      "Content-Type": 'application/json'
    }
  }
}


async function sleep(time) {
  return new Promise((resolve) => { setTimeout(resolve, time) })
}

async function polling(path, options) {
  for (i = 0; i < 4; i++) {
    const result = await fetch(`${API_ROOT_URL}/${path}`, options)
    if (result.status !== 404) {
      return result
    }
    await sleep(Math.min(1000 * 2 ** i, 30 * 1000))
  }
  throw Error("Eventual consistency error")
}


async function createEservice(token, { givenEserviceName = null , withPolling = false }) {
  const eserviceName = givenEserviceName || `e-service-${Math.random()}`
  const postEService = packEservice(eserviceName, token)  
  const response = await fetch(`${API_ROOT_URL}/eservices`, postEService)
  if (withPolling) {
    const eserviceId = (await response.json()).id
    await polling(`producers/eservices/${eserviceId}`, optinsForGetEServicesById(token))
  }
  
  return { eserviceName, response }
  
}

When("l'utente crea un e-service con lo stesso nome", async function () {
  const { response } = await createEservice(this.token, { givenEserviceName: this.eserviceName, withPolling: false })
  this.response = response
});

Given("l'utente ha già creato un e-service", async function () {
  const { eserviceName, response } = await createEservice(this.token, { withPolling: true })
  this.eserviceName = eserviceName
  this.response = response
});

When("l'utente crea un e-service", async function () {
  const { eserviceName, response } = await createEservice(this.token, {})
  this.eserviceName = eserviceName
  this.response = response
});

Then("la creazione restituisce errore - {string}", function (statusCode) {
  assert.equal(this.response.status, Number(statusCode))
});

Then("si ottiene status code {string}", function (statusCode) {
  assert.equal(this.response.status, Number(statusCode))
});
