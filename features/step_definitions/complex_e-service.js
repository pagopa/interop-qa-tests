const assert = require('assert');
const { Given, When, Then } = require('@cucumber/cucumber');

const TOKEN = {
  admin: '',
  api: '',
  security: ''
}

const API_ROOT_URL = 'https://selfcare.dev.interop.pagopa.it/backend-for-frontend/0.0'

function packEservice(name, role) {
  return {
    method: 'POST',
    headers: {
      Authorization: 'Bearer ' + TOKEN[role],
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

Given('un utente con ruolo {string} dell\'ente {string}', function(role, tenantType) {
  this.role = role
  this.tenantType = tenantType
})

When('creo un e-service', async function () {
  await sleep(3000)
  this.response = await fetch(API_ROOT_URL + '/eservices', 
    packEservice(
      `e-service-${Math.random()}-${this.tenantType}-${this.role}`,
      this.role
    ), 
  ) 
});

Then('si ottiene status code {string}', function (statusCode) {
  assert.equal(this.response.status, Number(statusCode))
});