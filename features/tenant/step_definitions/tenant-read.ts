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
  "l'utente richiede la lettura dell'aderente {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, { token: z.string() });
    const tenantId = getOrganizationId(tenantType); // alternative query: this.tenantType
    await apiClient.tenants.getTenant(
      tenantId,
      getAuthorizationHeader(this.token)
    );
  }
);
