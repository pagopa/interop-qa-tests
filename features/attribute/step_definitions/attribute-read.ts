import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di lettura di quel attributo",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });

    this.response = await apiClient.attributes.getAttributeById(
      this.attributeId,
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(this.response);
  }
);
