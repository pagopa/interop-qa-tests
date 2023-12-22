import { When, Given } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  makePolling,
  assertContextSchema,
} from "../../utils/commons";
import { apiClient } from "../../api";
import { createEservice } from "./e-service-creation";

When("l'utente crea una versione di un e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
  });

  const response = await createDescriptor(this.token, this.eserviceId);
  this.response = response;
});

async function createDescriptor(
  token: string,
  eserviceId: string,
  withPolling = false
) {
  const response = await apiClient.eservices.createDescriptor(
    eserviceId,
    {
      description: "Questo è un e-service di test",
      audience: ["api/v1"],
      voucherLifespan: 60,
      dailyCallsPerConsumer: 10,
      dailyCallsTotal: 100,
      agreementApprovalPolicy: "AUTOMATIC",
      attributes: {
        certified: [],
        declared: [],
        verified: [],
      },
    },
    getAuthorizationHeader(token)
  );

  const descriptorId = response.data.id;

  if (withPolling) {
    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          { headers: { Authorization: "Bearer " + token } }
        ),
      (res) => res.status !== 404
    );
  }
  return response;
}

Given(
  "l'utente ha già creato una versione di e-service in bozza",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });

    const { eserviceId } = await createEservice(this.token, {
      withPolling: true,
    });
    await createDescriptor(this.token, eserviceId, true);
    this.eserviceId = eserviceId;
  }
);
