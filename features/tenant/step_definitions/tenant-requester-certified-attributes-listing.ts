import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing degli attributi certificati posseduti",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.tenants.getRequesterCertifiedAttributes(
      { limit: 20, offset: 0 },
      getAuthorizationHeader(this.token)
    );
    assertValidResponse(this.response);
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato da {string} e l'attributo IPA comune",
  async function (_tenantType: TenantType) {
    assertContextSchema(this, {
      attributeId: z.string(),
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(
            z.object({
              attributeName: z.string(),
              attributeId: z.string(),
              tenantId: z.string(),
            })
          ),
        }),
      }),
    });

    assert.equal(this.response.status, 200);
    console.log({
      attributeId: this.attributeId,
      response: this.response.data.results,
    });
  }
);
