import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  assertValidResponse,
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
    let size = 50;
    let offset = 0;
    this.results = [];
    while (size === 50) {
      this.response = await apiClient.tenants.getRequesterCertifiedAttributes(
        { limit: 50, offset },
        getAuthorizationHeader(this.token)
      );
      assertValidResponse(this.response);
      this.results = this.results.concat(this.response.data.results);
      size = this.response.data.results.length;
      offset = offset + size;
    }
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato a {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      attributeId: z.string(),
      response: z.object({
        status: z.number(),
      }),
      results: z.array(
        z.object({
          attributeId: z.string(),
          tenantId: z.string(),
        })
      ),
    });

    assert.equal(this.response.status, 200);

    const tenantId = getOrganizationId(tenantType);

    assert.ok(
      this.results.some(
        (a) => a.attributeId === this.attributeId && a.tenantId === tenantId
      ),
      "L'attributo assegnato non è presente nella lista degli attributi certificati"
    );
  }
);
