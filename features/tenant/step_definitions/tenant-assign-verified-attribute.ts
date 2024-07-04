import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente assegna a {string} l'attributo verificato precedentemente creato",
  async function (tenantType: TenantType) {
    assertContextSchema(this, { token: z.string(), attributeId: z.string() });
    const tenantId = getOrganizationId(tenantType);
    this.response = await apiClient.tenants.verifyVerifiedAttribute(
      tenantId,
      {
        id: this.attributeId,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente assegna a {string} l'attributo verificato precedentemente creato con data di scadenza nel futuro",
  async function (tenantType: TenantType) {
    assertContextSchema(this, { token: z.string(), attributeId: z.string() });
    const tenantId = getOrganizationId(tenantType);
    const date = new Date();
    date.setDate(date.getDate() + 7);

    this.response = await apiClient.tenants.verifyVerifiedAttribute(
      tenantId,
      {
        id: this.attributeId,
        expirationDate: date.toISOString(),
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente assegna a {string} l'attributo verificato precedentemente creato con data di scadenza nel passato",
  async function (tenantType: TenantType) {
    assertContextSchema(this, { token: z.string(), attributeId: z.string() });
    const tenantId = getOrganizationId(tenantType);
    const date = new Date();
    this.response = await apiClient.tenants.verifyVerifiedAttribute(
      tenantId,
      {
        id: this.attributeId,
        expirationDate: date.setDate(date.getDate() - 7).toString(),
      },
      getAuthorizationHeader(this.token)
    );
  }
);
