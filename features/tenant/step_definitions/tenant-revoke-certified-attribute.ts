import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente revoca l'attributo precedentemente creato e assegnato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      tenantId: z.string(),
      attributeId: z.string(),
    });

    this.response = await apiClient.tenants.revokeCertifiedAttribute(
      this.tenantId,
      this.attributeId,
      getAuthorizationHeader(this.token)
    );
  }
);
