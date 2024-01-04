import assert from "assert";
import { readFileSync } from "fs";
import { File } from "buffer";
import { Given, When, Then } from "@cucumber/cucumber";
import { AxiosResponse } from "axios";
import { z } from "zod";
import zip from "lodash/zip";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  makePolling,
  executePromisesInParallelChunks,
} from "../../../utils/commons";
import { CreatedResource } from "../../../api/models";
import { Party, Role } from "./common-steps";

const PUBLISHED_ESERVICES = 9;
const SUSPENDED_ESERVICES = 6;
const TOTAL_ESERVICES = PUBLISHED_ESERVICES + SUSPENDED_ESERVICES;

Given(
  "un {string} di {string} ha già creato più di 12 e-services in catalogo in stato Published o Suspended",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      tokens: z.record(z.string(), z.record(z.string(), z.string())),
    });

    const token = this.tokens[party][role];

    /**
     * To speed up the process and avoid the BFF rate limit restriction,
     * we are calling each service in parallel chunks.
     */

    // 1. Create the draft e-services
    const arr = new Array(TOTAL_ESERVICES).fill(0);
    const eserviceIds = await executePromisesInParallelChunks(
      arr.map((_, i) => createEService.bind(null, i, token))
    );

    // 2. For each e-service, create his own draft descriptor
    const descriptorIds = await executePromisesInParallelChunks(
      eserviceIds.map((eserviceId) =>
        createDescriptorDraft.bind(null, eserviceId, token)
      )
    );

    // 2.1. Zip the two arrays
    const ids = zip(eserviceIds, descriptorIds) as Array<[string, string]>;

    // 3. For each draft descriptor, add the interface. This is needed in order to publish the descriptor.
    await executePromisesInParallelChunks(
      ids.map(([eserviceId, descriptorId]) =>
        addInterfaceToDescriptor.bind(null, eserviceId, descriptorId, token)
      )
    );

    // 4. Publish the descriptors
    await executePromisesInParallelChunks(
      ids.map(([eserviceId, descriptorId]) =>
        publishDescriptor.bind(null, eserviceId, descriptorId, token)
      )
    );

    // 5. Suspend the desired number of descriptors
    const idsToSuspend = ids.slice(0, SUSPENDED_ESERVICES);
    await executePromisesInParallelChunks(
      idsToSuspend.map(([eserviceId, descriptorId]) =>
        suspendDescriptor.bind(null, eserviceId, descriptorId, token)
      )
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
        q: this.TEST_SEED,
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
      Math.min(12, TOTAL_ESERVICES)
    );
  }
);

When(
  "l'utente richiede una operazione di listing limitata ai primi 12 e-services dell'erogatore {string}",
  async function (producer: Party) {
    assertContextSchema(this, {
      token: z.string(),
    });
    const producerId = getOrganizationId(producer);
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset: 0,
        q: this.TEST_SEED,
        states: [],
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
    this.producerId = producerId;
  }
);

Then(
  "si ottiene status code {string} e la lista degli eservices dell'erogatore specificato",
  function (statusCode: string) {
    assert.equal(this.response.status, Number(statusCode));
    assert.equal(
      this.response.data.pagination.totalCount,
      PUBLISHED_ESERVICES + SUSPENDED_ESERVICES
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
