import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType } from "../../../utils/commons";
import { AgreementState } from "../../../api/models";

Given(
  "{string} ha un agreement attivo per ciascun e-service di {string}",
  async function (consumer: TenantType, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const token = await getToken(consumer);

    const agreementsIds = await Promise.all(
      this.publishedEservicesIds.map(([eserviceId, descriptorId]) =>
        dataPreparationService.createAgreement(token, eserviceId, descriptorId)
      )
    );

    await Promise.all(
      agreementsIds.map((agreementId) =>
        dataPreparationService.submitAgreement(token, agreementId)
      )
    );
  }
);

Given(
  "{string} ha un agreement in stato {string} per l'e-service numero {int} di {string}",
  async function (
    consumer: TenantType,
    agreementState: AgreementState,
    eserviceIndex: number,
    _producer: string
  ) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const token = await getToken(consumer);
    const [eserviceId, descriptorId] =
      this.publishedEservicesIds[eserviceIndex];
    await dataPreparationService.createAgreementWithGivenState(
      token,
      agreementState,
      eserviceId,
      descriptorId
    );
  }
);

Given(
  "{string} ha già pubblicato una nuova versione per {int} di questi e-service",
  async function (tenantType: TenantType, descriptorsCount: number) {
    assertContextSchema(this, {
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });

    const token = await getToken(tenantType);
    const eserviceIds = this.publishedEservicesIds
      .slice(0, descriptorsCount)
      .map(([eserviceId, _]) => eserviceId);

    const descriptorCreation = async (eserviceId: string) => {
      const descriptorId =
        await dataPreparationService.createNextDraftDescriptor(
          token,
          eserviceId
        );
      await dataPreparationService.bringDescriptorToGivenState({
        token,
        eserviceId,
        descriptorId,
        descriptorState: "PUBLISHED",
      });

      return [eserviceId, descriptorId];
    };
    await Promise.all(
      eserviceIds.map((eserviceId) => descriptorCreation(eserviceId))
    );
  }
);

When(
  "l'utente richiede una operazione di listing limitata alle prime {int} richieste di fruizione",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );
    this.response = await apiClient.consumers.getConsumerAgreements(
      {
        eservicesIds,
        limit,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );
    this.response = await apiClient.consumers.getConsumerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione ai propri e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );

    this.response = await apiClient.producers.getProducerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione che ha creato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );
    this.response = await apiClient.consumers.getConsumerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
        // consumersIds: [getOrganizationId(this.tenantType)],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione per {int} specifici e-service",
  async function (numberEservices: number) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds
      .map(([eserviceId]) => eserviceId)
      .slice(0, numberEservices);
    this.response = await apiClient.producers.getProducerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione di {string} che sono in stato {string} e {string}",
  async function (
    consumer: TenantType,
    agreementState1: AgreementState,
    agreementState2: AgreementState
  ) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );
    this.response = await apiClient.consumers.getConsumerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
        // consumersIds: [getOrganizationId(consumer)],
        producersIds: [getOrganizationId(this.tenantType)],
        states: [agreementState1, agreementState2],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione aggiornabili",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );
    this.response = await apiClient.consumers.getConsumerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
        showOnlyUpgradeable: true,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(
      ([eserviceId]) => eserviceId
    );
    this.response = await apiClient.consumers.getConsumerAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} richiest(e)(a) di fruizione",
  function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, count);
  }
);
