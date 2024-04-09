import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../common-steps";
import { PurposeVersionState } from "../../../api/models";

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
