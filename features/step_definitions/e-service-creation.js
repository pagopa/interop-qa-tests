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

async function sleep(time) {
  return new Promise((resolve) => { setTimeout(resolve, time) })
}

async function createEservice(token, givenEserviceName) {
  const eserviceName = givenEserviceName || `e-service-${Math.random()}`
  const eservice = packEservice(eserviceName, token)  
  const response = await fetch(`${API_ROOT_URL}/eservices`, eservice)
  return { eserviceName, response }
}

Given("l'utente crea un e-service con lo stesso nome", async function () {
  await sleep(3000)
  const { response } = await createEservice(this.token, this.eserviceName)
  this.response = response
});

When("l'utente crea un e-service", async function () {
  const { eserviceName, response } = await createEservice(this.token)
  this.eserviceName = eserviceName
  this.response = response
});

Then("la creazione restituisce errore - {string}", function (statusCode) {
  assert.equal(this.response.status, Number(statusCode))
});

Then("si ottiene status code {string}", function (statusCode) {
  assert.equal(this.response.status, Number(statusCode))
});
