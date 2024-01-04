import assert from "assert";
import { readFileSync } from "fs";
import { File } from "buffer";
import { Given, When, Then } from "@cucumber/cucumber";
import { AxiosResponse } from "axios";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  TEST_SEED,
  assertContextSchema,
  getAuthorizationHeader,
  makePolling,
  runParallelPromisesInChunks,
} from "../../../utils/commons";
import { CreatedResource } from "../../../api/models";

const PUBLISHED_ESERVICES = 9;
const SUSPENDED_ESERVICES = 6;
const PROMISES_CHUNK_SIZE = 5;

Given(
  "esistono più di 12 e-services in catalogo in stato Published o Suspended",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    const eserviceIds = await runParallelPromisesInChunks(
      Array.from(
        { length: PUBLISHED_ESERVICES + SUSPENDED_ESERVICES },
        (_, i) => createEService.bind(null, i, this.token)
      ),
      PROMISES_CHUNK_SIZE
    );

    const descriptorIds = await runParallelPromisesInChunks(
      eserviceIds.map((eserviceId) =>
        createDescriptorDraft.bind(null, eserviceId, this.token)
      ),
      PROMISES_CHUNK_SIZE
    );

    await runParallelPromisesInChunks(
      eserviceIds.map((eserviceId, index) =>
        addInterfaceToDescriptor.bind(
          null,
          eserviceId,
          descriptorIds[index],
          this.token
        )
      ),
      PROMISES_CHUNK_SIZE
    );

    await runParallelPromisesInChunks(
      eserviceIds.map((eserviceId, index) =>
        publishDescriptor.bind(
          null,
          eserviceId,
          descriptorIds[index],
          this.token
        )
      ),
      PROMISES_CHUNK_SIZE
    );

    const eservicesIdsToSuspend = eserviceIds.slice(0, SUSPENDED_ESERVICES);
    const descriptorIdsToSuspend = descriptorIds.slice(0, SUSPENDED_ESERVICES);

    await runParallelPromisesInChunks(
      eservicesIdsToSuspend.map((eserviceId, index) =>
        suspendDescriptor.bind(
          null,
          eserviceId,
          descriptorIdsToSuspend[index],
          this.token
        )
      ),
      PROMISES_CHUNK_SIZE
    );
  }
);

When(
  "l'utente richiede una operazione di listing limitata ai primi 12",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
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
  response: AxiosResponse<CreatedResource | void, any> // eslint-disable-line @typescript-eslint/no-explicit-any
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

async function createEService(i: number, token: string) {
  const eserviceCreationResponse = await apiClient.eservices.createEService(
    {
      name: `eservice-${i}${TEST_SEED}`,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(token)
  );
  assertValidResponse(eserviceCreationResponse);
  const eserviceId = eserviceCreationResponse.data.id;

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDetails(
        eserviceId,
        getAuthorizationHeader(token)
      ),
    (res) => res.status !== 404
  );

  return eserviceId;
}

async function createDescriptorDraft(eserviceId: string, token: string) {
  const descriptorCreationResponse = await apiClient.eservices.createDescriptor(
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
  assertValidResponse(descriptorCreationResponse);
  const descriptorId = descriptorCreationResponse.data.id;

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDescriptor(
        eserviceId,
        descriptorId,
        getAuthorizationHeader(token)
      ),
    (res) => res.status !== 404
  );

  return descriptorId;
}

async function addInterfaceToDescriptor(
  eserviceId: string,
  descriptorId: string,
  token: string
) {
  const blobFile = new Blob([readFileSync("./utils/interface.yaml")]);
  const file = new File([blobFile], "interface.yaml");

  const response = await apiClient.eservices.createEServiceDocument(
    eserviceId,
    descriptorId,
    {
      kind: "INTERFACE",
      prettyName: "Interfaccia",
      doc: file,
    },
    getAuthorizationHeader(token)
  );

  assertValidResponse(response);

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDescriptor(
        eserviceId,
        descriptorId,
        getAuthorizationHeader(token)
      ),
    (res) => res.data.interface !== undefined
  );
}

async function publishDescriptor(
  eserviceId: string,
  descriptorId: string,
  token: string
) {
  await apiClient.eservices.publishDescriptor(
    eserviceId,
    descriptorId,
    getAuthorizationHeader(token)
  );

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDescriptor(
        eserviceId,
        descriptorId,
        getAuthorizationHeader(token)
      ),
    (res) => res.data.state === "PUBLISHED"
  );
}

async function suspendDescriptor(
  eserviceId: string,
  descriptorId: string,
  token: string
) {
  await apiClient.eservices.suspendDescriptor(
    eserviceId,
    descriptorId,
    getAuthorizationHeader(token)
  );

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDescriptor(
        eserviceId,
        descriptorId,
        getAuthorizationHeader(token)
      ),
    (res) => res.data.state === "SUSPENDED"
  );
}
