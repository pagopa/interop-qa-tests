import { Given, When } from "@cucumber/cucumber";
import { getAuthorizationHeader, makePolling } from "../../utils/commons";
import { apiClient } from "../../api";
import { assertValidResponse } from "./e-service-catalog-listing";

When(
  "l'utente crea una versione di un e-service",
  async function (this: {
    token: string;
    eserviceId: string;
    response: unknown;
  }) {
    this.response = await apiClient.eservices.createDescriptor(
      this.eserviceId,
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
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "l'utente ha già creato una versione in bozza per quell'eservice",
  async function (this: { token: string; eserviceId: string }) {
    const response = await apiClient.eservices.createDescriptor(
      this.eserviceId,
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
      getAuthorizationHeader(this.token)
    );

    const descriptorId = response.data.id;
    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          this.eserviceId,
          descriptorId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.status !== 404
    );
  }
);
