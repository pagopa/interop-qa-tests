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
  "l'utente assegna a {string} l'attributo certificato precedentemente creato",
  async function (tenantType: TenantType) {
    assertContextSchema(this, { token: z.string(), attributeId: z.string() });
    const tenantId = getOrganizationId(tenantType);
    this.response = await apiClient.tenants.addCertifiedAttribute(
      tenantId,
      {
        id: this.attributeId,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
