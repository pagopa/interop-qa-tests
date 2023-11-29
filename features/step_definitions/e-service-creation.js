const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

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

Given("l'utente ha creato un e-service {string}", async function (eserviceName) {
  await sleep(3000)
  const eservice = packEservice(eserviceName, this.token)  
  this.response = await fetch(`${API_ROOT_URL}/eservices`, eservice)
});

When("l'utente crea un e-service", async function () {
  await sleep(3000)
  const eserviceName = `e-service-${Math.random()}`
  const eservice = packEservice(eserviceName, this.token)  
  this.response = await fetch(`${API_ROOT_URL}/eservices`, eservice)
});

When("l'utente crea un e-service {string}", async function (eserviceName) {
  await sleep(3000)
  const eservice = packEservice(eserviceName, this.token)  
  this.response = await fetch(`${API_ROOT_URL}/eservices`, eservice)
});

Then("l'e-service viene creato correttamente", function () {
  assert.equal(this.response.status, 200)
});

Then("la creazione restituisce errore - {string}", function (statusCode) {
  assert.equal(this.response.status, Number(statusCode))
});
