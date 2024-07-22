import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già verificato l'attributo verificato a {string} con una data di scadenza nel futuro",
  async function (
    verifierTenantType: TenantType,
    targetTenantType: TenantType
  ) {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });
    const date = new Date();
    date.setDate(date.getDate() + 7);
    const verifierId = getOrganizationId(verifierTenantType);
    const tenantId = getOrganizationId(targetTenantType);
    await dataPreparationService.assignVerifiedAttributeToTenant(
      this.token,
      tenantId,
      verifierId,
      this.attributeId,
      date.toISOString()
    );
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo di {string} con una data di scadenza nel futuro",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });
    const date = new Date();
    date.setDate(date.getDate() + 7);
    const tenantId = getOrganizationId(tenantType);

    this.response = await apiClient.tenants.updateVerifiedAttribute(
      tenantId,
      this.attributeId,
      { expirationDate: date.toISOString() },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo di {string} rimuovendo la data di scadenza",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });
    const tenantId = getOrganizationId(tenantType);

    this.response = await apiClient.tenants.updateVerifiedAttribute(
      tenantId,
      this.attributeId,
      { expirationDate: undefined },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo di {string} con una data di scadenza nel passato",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });
    const date = new Date();
    date.setDate(date.getDate() - 7);
    const tenantId = getOrganizationId(tenantType);

    this.response = await apiClient.tenants.updateVerifiedAttribute(
      tenantId,
      this.attributeId,
      { expirationDate: date.toISOString() },
      getAuthorizationHeader(this.token)
    );
  }
);
