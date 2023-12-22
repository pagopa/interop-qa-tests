import assert from "assert";
import { readFileSync } from "fs";
import { File } from "buffer";
import { Given, When, Then } from "@cucumber/cucumber";
import { AxiosResponse } from "axios";
import { apiClient } from "../../api";
import {
  TEST_SEED,
  getAuthorizationHeader,
  makePolling,
} from "../../utils/commons";
import { CreatedResource } from "../../api/models";

const TOTAL_ESERVICES = 20;
const PUBLISHED_ESERVICES = 6;
const SUSPENDED_ESERVICES = 9;

Given(
  "esistono più di 12 e-services in catalogo in stato Published o Suspended",
  async function () {
    const eservicesIds: string[] = [];
    const descriptorIds: string[] = [];
    for (let i = 0; i < TOTAL_ESERVICES; i++) {
      const eserviceCreationResponse = await apiClient.eservices.createEService(
        {
          name: `eservice-${i}${TEST_SEED}`,
          description: "Questo è un e-service di test",
          technology: "REST",
          mode: "DELIVER",
        },
        getAuthorizationHeader(this.token)
      );
      const eserviceId = eserviceCreationResponse.data.id;

      assertValidResponse(eserviceCreationResponse);

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDetails(
            eserviceId,
            getAuthorizationHeader(this.token)
          ),
        (res) => res.status !== 404
      );

      eservicesIds.push(eserviceId);

      const descriptorCreationResponse =
        await apiClient.eservices.createDescriptor(
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
          getAuthorizationHeader(this.token)
        );

      const descriptorId = descriptorCreationResponse.data.id;

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eserviceId,
            descriptorId,
            getAuthorizationHeader(this.token)
          ),
        (res) => res.status !== 404
      );
      descriptorIds.push(descriptorId);
    }

    for (let i = 0; i < PUBLISHED_ESERVICES + SUSPENDED_ESERVICES; i++) {
      const blobFile = new Blob([readFileSync("./utils/interface.yaml")]);
      const file = new File([blobFile], "interface.yaml");

      await apiClient.eservices.createEServiceDocument(
        eservicesIds[i],
        descriptorIds[i],
        {
          kind: "INTERFACE",
          prettyName: "Interfaccia",
          doc: file,
        },
        getAuthorizationHeader(this.token)
      );

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eservicesIds[i],
            descriptorIds[i],
            getAuthorizationHeader(this.token)
          ),
        (res) => res.data.interface !== undefined
      );

      await apiClient.eservices.publishDescriptor(
        eservicesIds[i],
        descriptorIds[i],
        getAuthorizationHeader(this.token)
      );

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eservicesIds[i],
            descriptorIds[i],
            getAuthorizationHeader(this.token)
          ),
        (res) => res.data.state === "PUBLISHED"
      );
    }

    for (let i = 0; i < SUSPENDED_ESERVICES; i++) {
      await apiClient.eservices.suspendDescriptor(
        eservicesIds[i],
        descriptorIds[i],
        getAuthorizationHeader(this.token)
      );

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eservicesIds[i],
            descriptorIds[i],
            getAuthorizationHeader(this.token)
          ),
        (res) => res.data.state === "SUSPENDED"
      );
    }
  }
);

When(
  "l'utente richiede una operazione di listing limitata ai primi 12",
  async function () {
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset: 0,
        q: TEST_SEED,
        states: ["PUBLISHED", "SUSPENDED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {string} e la lista di 12 e-services",
  function (statusCode: string) {
    assert.equal(this.response.status, Number(statusCode));
    assert.equal(
      this.response.data.results.length,
      Math.min(12, PUBLISHED_ESERVICES + SUSPENDED_ESERVICES)
    );
  }
);

export function assertValidResponse(
  response: AxiosResponse<CreatedResource, any> // eslint-disable-line @typescript-eslint/no-explicit-any
) {
  if (response.status !== 200) {
    throw Error(
      `Something went wrong: ${JSON.stringify(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (response.data as unknown as any).errors
      )}`
    );
  }
}
