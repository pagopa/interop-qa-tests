import assert from "assert";
import { readFileSync } from "fs";
import { File } from "buffer";
import { Given, When, Then } from "@cucumber/cucumber";
import { AxiosResponse } from "axios";
import { z } from "zod";
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

const PUBLISHED_ESERVICES = 1;
const SUSPENDED_ESERVICES = 1;
const DRAFT_ESERVICES = 1;
const TOTAL_ESERVICES =
  PUBLISHED_ESERVICES + SUSPENDED_ESERVICES + DRAFT_ESERVICES;

Given(
  "un {string} di {string} ha già creato più di 12 e-services in catalogo in stato Published o Suspended",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      tokens: z.record(z.string(), z.record(z.string(), z.string())),
      TEST_SEED: z.string(),
    });

    const token = this.tokens[party][role];

    /**
     * To speed up the process and avoid the BFF rate limit restriction,
     * we are calling each service in parallel chunks.
     */

    // 1. Create the draft e-services with draft descriptors
    const arr = new Array(TOTAL_ESERVICES).fill(0);
    const allIds = await executePromisesInParallelChunks(
      arr.map((_, i) => async () => {
        const eserviceId = await createEService(i, token, this.TEST_SEED);
        const descriptorId = await createDescriptorDraft(eserviceId, token);

        return [eserviceId, descriptorId];
      })
    );

    // 2. Take only the ids of the e-services that needs to be published and suspended
    const idsToPublishAndSuspend = allIds.slice(
      0,
      SUSPENDED_ESERVICES + PUBLISHED_ESERVICES
    );

    // 3. For each draft descriptor, in order to publish it, add the document interface
    await executePromisesInParallelChunks(
      idsToPublishAndSuspend.map(([eserviceId, descriptorId]) =>
        addInterfaceToDescriptor.bind(null, eserviceId, descriptorId, token)
      )
    );

    // 4. Publish the descriptors
    await executePromisesInParallelChunks(
      idsToPublishAndSuspend.map(([eserviceId, descriptorId]) =>
        publishDescriptor.bind(null, eserviceId, descriptorId, token)
      )
    );

    // 5. Suspend the desired number of descriptors
    const idsToSuspend = idsToPublishAndSuspend.slice(0, SUSPENDED_ESERVICES);
    await executePromisesInParallelChunks(
      idsToSuspend.map(([eserviceId, descriptorId]) =>
        suspendDescriptor.bind(null, eserviceId, descriptorId, token)
      )
    );
  }
);

Given(
  "ente_fruitore ha già richiesto l'approvazione dell'agreement per un eservice di ComuneDiMilano",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eservicesIds: z.array(z.string()),
      descriptorIds: z.array(z.string()),
    });

    const eserviceId = this.eservicesIds[SUSPENDED_ESERVICES];
    const descriptorId = this.descriptorIds[SUSPENDED_ESERVICES];
    this.response = await apiClient.agreements.createAgreement(
      { eserviceId, descriptorId },
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(this.response);

    this.agreementId = this.response.data.id;
    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.agreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.status !== 404
    );

    this.response = await apiClient.agreements.submitAgreement(
      this.agreementId,
      {},
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(this.response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.agreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.data.state === "PENDING"
    );
  }
);

Given(
  "un {string} di {string} ha già approvato la richiesta di agreement di ente_fruitore",
  async function (role: Role, party: Party) {
    const token = this.tokens[party][role];
    assertContextSchema(this, {
      tokens: z.record(z.string(), z.record(z.string(), z.string())),
      agreementId: z.string(),
    });

    this.response = await apiClient.agreements.activateAgreement(
      this.agreementId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(this.response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "ACTIVE"
    );
  }
);

When(
  "l'utente richiede la lista di eservices per i quali ha almeno un agreement attivo",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset: 0,
        q: this.TEST_SEED,
        states: ["PUBLISHED"],
        agreementStates: ["ACTIVE"],
      },
      getAuthorizationHeader(this.token)
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
      Math.min(12, PUBLISHED_ESERVICES + SUSPENDED_ESERVICES)
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
        states: ["PUBLISHED", "SUSPENDED"],
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

Then(
  "si ottiene status code {string} e la lista degli eservices di cui è fruitore con un agreement attivo",
  function (statusCode: string) {
    assert.equal(this.response.status, Number(statusCode));
    assert.equal(this.response.data.pagination.totalCount, 1);
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

async function createEService(i: number, token: string, testSeed: string) {
  const eserviceCreationResponse = await apiClient.eservices.createEService(
    {
      name: `eservice-${i}-${testSeed}`,
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
      agreementApprovalPolicy: "MANUAL",
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
