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
      attributeId: z.string(),
    });
    this.response = await apiClient.tenants.revokeDeclaredAttribute(
      this.attributeId,
      getAuthorizationHeader(this.token)
    );
  }
);
