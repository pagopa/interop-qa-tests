import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getRandomInt,
  getRiskAnalysis,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Role, TenantType } from "../../common-steps";
import { PurposeVersionState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

When(
  "l'utente erogatore richiede una operazione di listing delle finalità limitata alle prime {int} finalità",
  async function (limit: number) {
    assertContextSchema(this, { token: z.string(), tenantType: TenantType });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        offset: 0,
        limit,
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} finalità",
  async function (statusCode: number, count: number) {
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

When(
  "l'utente erogatore richiede una operazione di listing delle finalità con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset,
        limit: 50,
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità sui propri e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrata per fruitore {string}",
  async function (consumer: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    const producerId = getOrganizationId(this.tenantType);
    const consumerId = getOrganizationId(consumer);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
        producersIds: [producerId],
        consumersIds: [consumerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrata per il secondo e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità in stato {string}",
  async function (purposeState: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
        states: [purposeState],
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "un {string} di {string} ha già creato una finalità in stato {string} per quell'e-service contenente la keyword {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    purposeState: PurposeVersionState,
    keyword: string
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, "admin");
    const consumerId = getOrganizationId(tenantType);

    const { riskAnalysisForm } = getRiskAnalysis({
      completed: true,
      tenantType,
    });

    const title = `purpose ${this.TEST_SEED} - ${getRandomInt()} - ${keyword}`;
    this.purposeId = await dataPreparationService.createPurposeWithGivenState({
      token,
      testSeed: this.TEST_SEED,
      eserviceMode: "DELIVER",
      payload: {
        title,
        eserviceId: this.eserviceId,
        consumerId,
        riskAnalysisForm,
      },
      purposeState,
    });
  }
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    const producerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.producer.getProducerPurposes(
      {
        q: keyword,
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
        producersIds: [producerId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);
