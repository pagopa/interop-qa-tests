import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType } from "../../../utils/commons";

Given(
  "{string} ha già creato {int} e-services in catalogo in stato PUBLISHED o SUSPENDED e {int} in stato DRAFT",
  async function (
    tenantType: TenantType,
    countEservices: number,
    countDraftEservices: number
  ) {
    assertContextSchema(this);

    const token = await getToken(tenantType);
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
  async function (consumer: TenantType, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const token = await getToken(consumer);
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

When(
  "l'utente richiede la lista di e-services per i quali ha almeno un agreement attivo",
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
  async function (producer: TenantType) {
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
  "{string} ha già creato e pubblicato un e-service contenente la keyword {string}",
  async function (tenantType: TenantType, keyword: string) {
    assertContextSchema(this);

    const token = await getToken(tenantType);
    const eserviceName = `e-service-${this.TEST_SEED}-${keyword}`;
    this.eserviceId = await dataPreparationService.createEService(token, {
      name: eserviceName,
    });

    this.descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      this.eserviceId
    );

    await dataPreparationService.addInterfaceToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );

    await dataPreparationService.publishDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);
