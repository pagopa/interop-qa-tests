import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { Party, Role, SessionTokens } from "./common-steps";

Given(
  "un {string} di {string} ha già creato {int} e-services in catalogo in stato PUBLISHED o SUSPENDED e {int} in stato Draft",
  async function (
    role: Role,
    party: Party,
    countEservices: number,
    countDraftEservices: number
  ) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;
    const SUSPENDED_ESERVICES = Math.floor(countEservices / 2);
    const PUBLISHED_ESERVICES = countEservices - SUSPENDED_ESERVICES;
    const DRAFT_ESERVICES = countDraftEservices;
    const TOTAL_ESERVICES = countEservices + DRAFT_ESERVICES;

    // 1. Create the draft e-services with draft descriptors
    const arr = new Array(TOTAL_ESERVICES).fill(0);
    const createEServiceWithDescriptor = async (i: number) => {
      const eserviceId = await dataPreparationService.createEService(token, {
        name: `eservice-${i}-${this.TEST_SEED}`,
      });
      const descriptorId = await dataPreparationService.createDraftDescriptor(
        token,
        eserviceId
      );

      return [eserviceId, descriptorId];
    };
    const allIds = await Promise.all(
      arr.map((_, i) => createEServiceWithDescriptor(i))
    );

    // 2. Take only the ids of the e-services that needs to be published and suspended
    const idsToPublishAndSuspend = allIds.slice(
      0,
      SUSPENDED_ESERVICES + PUBLISHED_ESERVICES
    );

    // 3. For each draft descriptor, in order to publish it, add the document interface
    await Promise.all(
      idsToPublishAndSuspend.map(([eserviceId, descriptorId]) =>
        dataPreparationService.addInterfaceToDescriptor(
          token,
          eserviceId,
          descriptorId
        )
      )
    );

    // 4. Publish the descriptors
    await Promise.all(
      idsToPublishAndSuspend.map(([eserviceId, descriptorId]) =>
        dataPreparationService.publishDescriptor(
          token,
          eserviceId,
          descriptorId
        )
      )
    );

    // 5. Suspend the desired number of descriptors
    const idsToSuspend = idsToPublishAndSuspend.slice(0, SUSPENDED_ESERVICES);
    await Promise.all(
      idsToSuspend.map(([eserviceId, descriptorId]) =>
        dataPreparationService.suspendDescriptor(
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
  "{string} ha un agreement attivo con un e-service di {string}",
  async function (consumer: Party, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
      tokens: SessionTokens,
    });
    const token = this.tokens[consumer]!.admin!;
    const [eserviceId, descriptorId] = this.publishedEservicesIds[0];

    const agreementId = await dataPreparationService.createAgreement(
      token,
      eserviceId,
      descriptorId
    );

    await dataPreparationService.submitAgreement(token, agreementId);

    this.agreementId = agreementId;
    this.eserviceSubscribedId = eserviceId;
    this.descriptorSubscribedId = descriptorId;
  }
);

Given(
  "un {string} di {string} ha già approvato la richiesta di agreement di ente_fruitore",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = this.tokens[party]![role]!;

    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);

Given(
  "un {string} di {string} ha già sospeso la versione dell'eservice che ente_fruitore ha sottoscritto",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      agreementId: z.string(),
      eserviceSubscribedId: z.string(),
      descriptorSubscribedId: z.string(),
    });

    const token = this.tokens[party]![role]!;

    await dataPreparationService.suspendDescriptor(
      token,
      this.eserviceSubscribedId,
      this.descriptorSubscribedId
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
        states: ["PUBLISHED", "SUSPENDED"],
        agreementStates: ["ACTIVE"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede la lista di eservices che hanno almeno una versione in stato SUSPENDED, erogati da {string} e {string} per i quali ha almeno un agreement attivo che contengono la keyword di ricerca",
  async function (producer1: Party, producer2: Party) {
    assertContextSchema(this, {
      token: z.string(),
    });
    const producerId1 = getOrganizationId(producer1);
    const producerId2 = getOrganizationId(producer2);
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset: 0,
        q: this.TEST_SEED,
        states: ["SUSPENDED"],
        agreementStates: ["ACTIVE"],
        producersIds: [producerId1, producerId2],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing sul catalogo",
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

When(
  "l'utente richiede una operazione di listing sul catalogo limitata ai primi {int} e-services",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit,
        offset: 0,
        q: this.TEST_SEED,
        states: ["PUBLISHED", "SUSPENDED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing sul catalogo con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset,
        q: this.TEST_SEED,
        states: ["PUBLISHED", "SUSPENDED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services dell'erogatore {string}",
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
  }
);

When(
  "l'utente richiede una operazione di listing sul catalogo filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.catalog.getEServicesCatalog(
      {
        limit: 12,
        offset: 0,
        q: `${this.TEST_SEED}-${keyword}`,
        states: ["PUBLISHED", "SUSPENDED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "un {string} di {string} ha già creato e pubblicato un e-service contenente la keyword {string}",
  async function (role: Role, party: Party, keyword: string) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;
    const eserviceName = `e-service-${this.TEST_SEED}-${keyword}`;
    const eserviceId = await dataPreparationService.createEService(token, {
      name: eserviceName,
    });

    const descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      eserviceId
    );

    await dataPreparationService.addInterfaceToDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    await dataPreparationService.publishDescriptor(
      token,
      eserviceId,
      descriptorId
    );
  }
);
