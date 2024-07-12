import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente revoca l'attributo precedentemente dichiarato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      requiredDeclaredAttributes: z.array(z.array(z.string())),
    });
    const attributeId = this.requiredDeclaredAttributes[0][0];
    this.response = await apiClient.tenants.revokeDeclaredAttribute(
      attributeId,
      getAuthorizationHeader(this.token)
    );
  }
);
