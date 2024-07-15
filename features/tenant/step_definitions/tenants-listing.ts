import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli aderenti limitata a {int}",
  async function (count: number) {
    assertContextSchema(this, { token: z.string() });
    this.response = await apiClient.tenants.getTenants(
      { limit: count },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli aderenti filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, { token: z.string() });
    this.response = await apiClient.tenants.getTenants(
      { name: keyword, limit: 50 },
      getAuthorizationHeader(this.token)
    );
  }
);
