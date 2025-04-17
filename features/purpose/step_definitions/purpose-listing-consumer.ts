import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { TenantType } from "../../../utils/commons";
import { PurposeVersionState } from "../../../api/models";

When(
  "l'utente fruitore richiede una operazione di listing delle finalità limitata ai primi {int} risultati",
  async function (limit: number) {
    assertContextSchema(this, { token: z.string(), tenantType: TenantType });
    // const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.consumers.getConsumerPurposes(
      {
        offset: 0,
        limit,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente fruitore richiede una operazione di listing delle finalità con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    // const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.consumers.getConsumerPurposes(
      {
        offset,
        limit: 50,
        eservicesIds: [this.eserviceId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente fruitore richiede una operazione di listing delle sue finalità sugli e-services a cui è sottoscritto",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    // const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.consumers.getConsumerPurposes(
      {
        offset: 0,
        limit: 50,
        eservicesIds: [this.eserviceId],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente fruitore richiede una operazione di listing delle finalità filtrata per il secondo e-service",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    // const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.consumers.getConsumerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente fruitore richiede una operazione di listing delle finalità in stato {string}",
  async function (purposeState: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    // const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.consumers.getConsumerPurposes(
      {
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
        states: [purposeState],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente fruitore richiede una operazione di listing delle finalità filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
      tenantType: TenantType,
      eserviceId: z.string(),
    });
    // const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.consumers.getConsumerPurposes(
      {
        q: keyword,
        eservicesIds: [this.eserviceId],
        offset: 0,
        limit: 50,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
