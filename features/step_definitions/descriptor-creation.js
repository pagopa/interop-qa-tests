const { Given, When, Then } = require("@cucumber/cucumber");
const { createEservice, optionsForGetRoute, polling } = require("./e-service-creation");

const API_ROOT_URL =
  "https://selfcare.dev.interop.pagopa.it/backend-for-frontend/0.0";

When("l'utente crea una versione di un e-service", async function () {
  const response = await createDescriptor(this.token, this.eserviceId);
  this.response = response;
});

function postDescriptor(token) {
  return {
    method: "POST",
    headers: {
      Authorization: "Bearer " + token,
      "X-Correlation-Id": "abc",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      description: "Questo è un e-service di test",
      audience: ["api/v1"],
      voucherLifespan: 60,
      dailyCallsPerConsumer: 10,
      dailyCallsTotal: 100,
      agreementApprovalPolicy: "AUTOMATIC",
      attributes: {
        certified: [],
        declared: [],
        verified: []
      }
    }),
  };
}

async function createDescriptor(token, eserviceId, withPolling = false) {
  const response = await fetch(`${API_ROOT_URL}/eservices/${eserviceId}/descriptors`, postDescriptor(token));
  const descriptorId = (await response.json()).id;
  if (withPolling) {
    await polling(
      `producers/eservices/${eserviceId}/descriptors/${descriptorId}`,
      optionsForGetRoute(token)
    );
  }
  return response
}

Given("l'utente ha già creato una versione di e-service in bozza", async function () {
  const { eserviceId } = await createEservice(this.token, { withPolling: true })
  await createDescriptor(this.token, eserviceId, true)
  this.eserviceId = eserviceId
})
