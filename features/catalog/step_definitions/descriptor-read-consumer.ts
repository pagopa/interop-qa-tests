import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente fruitore richiede la lettura di quel descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    this.response = await apiClient.catalog.getCatalogEServiceDescriptor(
      this.eserviceId,
      this.descriptorId,
      getAuthorizationHeader(this.token)
    );
  }
);
