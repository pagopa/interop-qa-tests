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
import { TenantType, SessionTokens, Role } from "../../common-steps";
import { AgreementState } from "../../../api/models";

Given(
  "un {string} di {string} ha già creato {int} e-service(s) in stato PUBLISHED",
  async function (role: Role, tenantType: TenantType, totalEservices: number) {
    assertContextSchema(this);
    const token = getToken(this.tokens, tenantType, role);

    const arr = new Array(totalEservices).fill(0);
    const createEServiceWithPublishedDescriptor = async (i: number) => {
      const eserviceId = await dataPreparationService.createEService(token, {
        name: `eservice-${i}-${this.TEST_SEED}`,
      });
      const { descriptorId } =
        await dataPreparationService.createDescriptorWithGivenState({
          token,
          eserviceId,
          descriptorState: "PUBLISHED",
        });

      return [eserviceId, descriptorId];
    };
  
    this.publishedEservicesIds = await Promise.all(
      arr.map((_, i) => createEServiceWithPublishedDescriptor(i))
    );
  }
);

Given(
  "{string} ha un agreement attivo per ciascun e-service di {string}",
  async function (consumer: TenantType, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
      tokens: SessionTokens,
    });
    const token = getToken(this.tokens, consumer, "admin");
    await Promise.all(this.publishedEservicesIds.map(([eserviceId, descriptorId]) => dataPreparationService.createAgreement(token, eserviceId,
      descriptorId)));
  }
);

Given(
  "{string} ha un agreement in stato {string} per un e-service di {string}",
  async function (consumer: TenantType, agreementState: string, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
      tokens: SessionTokens,
    });
    const token = getToken(this.tokens, consumer, "admin");
    const [eserviceId, descriptorId] = this.publishedEservicesIds[0];
    await dataPreparationService.createAgreementWithGivenState(token, agreementState, eserviceId, descriptorId);
  }
);

Given(
  "{string} ha un agreement in stato {string} per un altro e-service di {string}",
  async function (consumer: TenantType, agreementState: string, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
      tokens: SessionTokens,
    });
    const token = getToken(this.tokens, consumer, "admin");
    const [eserviceId, descriptorId] = this.publishedEservicesIds[1];
    await dataPreparationService.createAgreementWithGivenState(token, agreementState, eserviceId, descriptorId);
  }
);

When(
  "l'utente richiede una operazione di listing limitata alle prime {int} richieste di fruizione",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(([eserviceId]) => eserviceId);
    this.response = await apiClient.agreements.getAgreements(
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
    const eservicesIds = this.publishedEservicesIds.map(([eserviceId]) => eserviceId);
    this.response = await apiClient.agreements.getAgreements(
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
    const eservicesIds = this.publishedEservicesIds.map(([eserviceId]) => eserviceId);
    this.response = await apiClient.agreements.getAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
        producersIds: [getOrganizationId(this.tenantType)]
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
    const eservicesIds = this.publishedEservicesIds.map(([eserviceId]) => eserviceId);
    this.response = await apiClient.agreements.getAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
        consumersIds: [getOrganizationId(this.tenantType)],
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
    const eservicesIds = this.publishedEservicesIds.map(([eserviceId]) => eserviceId).slice(0, numberEservices);
    this.response = await apiClient.agreements.getAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing delle richieste di fruizione di {string} che sono in stato {string}",
  async function (consumer: TenantType, agreementState: AgreementState) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map(([eserviceId]) => eserviceId);
    this.response = await apiClient.agreements.getAgreements(
      {
        eservicesIds,
        limit: 12,
        offset: 0,
        consumersIds: [getOrganizationId(consumer)],
        producersIds: [getOrganizationId(this.tenantType)],
        states: [agreementState]
      },
      getAuthorizationHeader(this.token)
    );
  },
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
