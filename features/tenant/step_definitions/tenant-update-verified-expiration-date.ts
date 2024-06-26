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
    const verifierId = getOrganizationId(verifierTenantType);
    this.tenantId = getOrganizationId(targetTenantType);
    await dataPreparationService.assignVerifiedAttributeToTenant(
      this.token,
      this.tenantId,
      verifierId,
      this.attributeId,
      date.setDate(date.getDate() + 7).toString()
    );
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel futuro",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantId: z.string(),
      attributeId: z.string(),
    });
    const date = new Date();
    this.response = await apiClient.tenants.updateVerifiedAttribute(
      this.tenantId,
      this.attributeId,
      { expirationDate: date.setDate(date.getDate() + 7).toString() },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo rimuovendo la data di scadenza",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantId: z.string(),
      attributeId: z.string(),
    });
    this.response = await apiClient.tenants.updateVerifiedAttribute(
      this.tenantId,
      this.attributeId,
      { expirationDate: undefined },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel passato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantId: z.string(),
      attributeId: z.string(),
    });
    const date = new Date();
    this.response = await apiClient.tenants.updateVerifiedAttribute(
      this.tenantId,
      this.attributeId,
      { expirationDate: date.setDate(date.getDate() - 7).toString() },
      getAuthorizationHeader(this.token)
    );
  }
);
