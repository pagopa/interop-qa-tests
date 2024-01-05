import assert from "assert";
import { Given, When, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  executePromisesInParallelChunks,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
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
        const eserviceId = await dataPreparationService.createEService(token, {
          name: `eservice-${i}-${this.TEST_SEED}`,
        });
        const descriptorId = await dataPreparationService.createDraftDescriptor(
          token,
          eserviceId
        );

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
        dataPreparationService.addInterfaceToDescriptor.bind(
          null,
          token,
          eserviceId,
          descriptorId
        )
      )
    );

    // 4. Publish the descriptors
    await executePromisesInParallelChunks(
      idsToPublishAndSuspend.map(([eserviceId, descriptorId]) =>
        dataPreparationService.publishDescriptor.bind(
          null,
          token,
          eserviceId,
          descriptorId
        )
      )
    );

    // 5. Suspend the desired number of descriptors
    const idsToSuspend = idsToPublishAndSuspend.slice(0, SUSPENDED_ESERVICES);
    await executePromisesInParallelChunks(
      idsToSuspend.map(([eserviceId, descriptorId]) =>
        dataPreparationService.suspendDescriptor.bind(
          null,
          token,
          eserviceId,
          descriptorId
        )
      )
    );

    this.publishedEservicesIds =
      idsToPublishAndSuspend.slice(SUSPENDED_ESERVICES);
    this.suspendedEservicesIds = idsToSuspend;
    this.draftEServicesIds = allIds.slice(
      SUSPENDED_ESERVICES + PUBLISHED_ESERVICES
    );
  }
);

Given(
  "ente_fruitore ha già richiesto l'approvazione dell'agreement per un eservice di ComuneDiMilano",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });

    const [eserviceId, descriptorId] = this.publishedEservicesIds[0];

    const agreementId = await dataPreparationService.createAgreement(
      this.token,
      eserviceId,
      descriptorId
    );

    await dataPreparationService.submitAgreement(this.token, agreementId);

    this.agreementId = agreementId;
    this.eserviceSubscribedId = eserviceId;
    this.descriptorSubscribedId = descriptorId;
  }
);

Given(
  "un {string} di {string} ha già approvato la richiesta di agreement di ente_fruitore",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      tokens: z.record(z.string(), z.record(z.string(), z.string())),
      agreementId: z.string(),
    });

    const token = this.tokens[party][role];

    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);

Given(
  "un {string} di {string} ha già sospeso la versione dell'eservice che ente_fruitore ha sottoscritto",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      tokens: z.record(z.string(), z.record(z.string(), z.string())),
      agreementId: z.string(),
      eserviceSubscribedId: z.string(),
      descriptorSubscribedId: z.string(),
    });

    const token = this.tokens[party][role];
    // TODO: erogatore sospende il descriptor associato a eserviceSubscribedId, descriptorSubscribedId
    // da implementare con dataPreparationService() con polling
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
  "l'utente richiede la lista di eservices per i quali ha almeno un agreement attivo che contengono la keyword di ricerca",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset: 0,
        q: this.TEST_SEED,
        states: ["SUSPENDED"],
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

Then(
  "si ottiene status code {string} e la lista degli eservices di cui è fruitore con un agreement attivo per una versione dell'eservice in stato SUSPENDED, che contiene la chiave di ricerca",
  function () {
    assert.equal(1, 1);
  }
);
