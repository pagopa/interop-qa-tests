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
} from "../../../utils/commons";
import { CreatedResource } from "../../../api/models";
import { Party, Role } from "./common-steps";

const TOTAL_ESERVICES = 4;
const PUBLISHED_ESERVICES = 2;
const SUSPENDED_ESERVICES = 2;

Given(
  "un {string} di {string} ha già creato più di 12 e-services in catalogo in stato Published o Suspended",
  async function (role: Role, party: Party) {
    const token = this.tokens[party][role];
    assertContextSchema(this, {
      tokens: z.record(z.string(), z.record(z.string(), z.string())),
    });
    const eservicesIds: string[] = [];
    const descriptorIds: string[] = [];
    for (let i = 0; i < TOTAL_ESERVICES; i++) {
      const eserviceCreationResponse = await apiClient.eservices.createEService(
        {
          name: `eservice-${i}${this.TEST_SEED}`,
          description: "Questo è un e-service di test",
          technology: "REST",
          mode: "DELIVER",
        },
        getAuthorizationHeader(token)
      );
      const eserviceId = eserviceCreationResponse.data.id;

      assertValidResponse(eserviceCreationResponse);

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDetails(
            eserviceId,
            getAuthorizationHeader(token)
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
            agreementApprovalPolicy: "MANUAL",
            attributes: {
              certified: [],
              declared: [],
              verified: [],
            },
          },
          getAuthorizationHeader(token)
        );

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
        getAuthorizationHeader(token)
      );

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eservicesIds[i],
            descriptorIds[i],
            getAuthorizationHeader(token)
          ),
        (res) => res.data.interface !== undefined
      );

      await apiClient.eservices.publishDescriptor(
        eservicesIds[i],
        descriptorIds[i],
        getAuthorizationHeader(token)
      );

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eservicesIds[i],
            descriptorIds[i],
            getAuthorizationHeader(token)
          ),
        (res) => res.data.state === "PUBLISHED"
      );
    }

    for (let i = 0; i < SUSPENDED_ESERVICES; i++) {
      await apiClient.eservices.suspendDescriptor(
        eservicesIds[i],
        descriptorIds[i],
        getAuthorizationHeader(token)
      );

      await makePolling(
        () =>
          apiClient.producers.getProducerEServiceDescriptor(
            eservicesIds[i],
            descriptorIds[i],
            getAuthorizationHeader(token)
          ),
        (res) => res.data.state === "SUSPENDED"
      );
    }
    this.eservicesIds = eservicesIds;
    this.descriptorIds = descriptorIds;
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

Then(
  "si ottiene status code {string} e la lista degli eservices di cui è fruitore con un agreement attivo",
  function (statusCode: string) {
    assert.equal(this.response.status, Number(statusCode));
    assert.equal(this.response.data.pagination.totalCount, 1);
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
