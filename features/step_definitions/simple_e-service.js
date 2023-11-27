const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

const ADMIN_TOKEN_GSP = ''
const API_ROOT_URL = 'https://selfcare.dev.interop.pagopa.it/backend-for-frontend/0.0'

function packEservice(name) {
  return {
    method: 'POST',
    headers: {
      Authorization: 'Bearer ' + ADMIN_TOKEN_GSP,
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
  return new Promise((resolve) => {
    setTimeout(resolve, time)
  })
}

Given('esiste un e-service titolo {string}', async function (name) {
  this.response = await fetch(API_ROOT_URL + '/eservices', packEservice(name))
})

When('creo un e-service {string}', async function (name) {
  await sleep(3000)
  this.response = await fetch(API_ROOT_URL + '/eservices', packEservice(name))
});

Then('l\'e-service viene creato correttamente', function () {
  assert.equal(this.response.status, 200)
});

Then('la creazione restituisce errore - 409 Conflict', function () {
  assert.equal(this.response.status, 409)
});