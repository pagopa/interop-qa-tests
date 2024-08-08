import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing degli attributi certificati assegnati",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.tenants.getRequesterCertifiedAttributes(
      { limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato a {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      attributeId: z.string(),
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(
            z.object({
              attributeId: z.string(),
              tenantId: z.string(),
            })
          ),
        }),
      }),
    });

    assert.equal(this.response.status, 200);

    const tenantId = getOrganizationId(tenantType);

    assert.ok(
      this.response.data.results.some(
        (a) => a.attributeId === this.attributeId && a.tenantId === tenantId
      ),
      "L'attributo assegnato non è presente nella lista degli attributi certificati"
    );
  }
);
