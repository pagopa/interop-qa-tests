import { When, Given } from "@cucumber/cucumber"
import { polling, optionsForGetRoute, createEservice } from "./e-service-creation";
import { API_ROOT_URL } from "./tokens";

When("l'utente crea una versione di un e-service", async function (this: { token: string, eserviceId: string, response: unknown }) {
  const response = await createDescriptor(this.token, this.eserviceId);
  this.response = response;
});

function postDescriptor(token: string) {
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

async function createDescriptor(token: string, eserviceId: string, withPolling = false) {
  const response = await fetch(`${API_ROOT_URL}/eservices/${eserviceId}/descriptors`, postDescriptor(token));
  const descriptorId = ((await response.json()) as { id: string }).id;
  if (withPolling) {
    await polling(
      `producers/eservices/${eserviceId}/descriptors/${descriptorId}`,
      optionsForGetRoute(token)
    );
  }
  return response
}

Given("l'utente ha già creato una versione di e-service in bozza", async function (this: { token: string, eserviceId: string }) {
  const { eserviceId } = await createEservice(this.token, { withPolling: true })
  await createDescriptor(this.token, eserviceId, true)
  this.eserviceId = eserviceId
})
