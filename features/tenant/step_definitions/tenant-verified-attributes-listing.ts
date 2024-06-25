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
  "l'utente richiede una operazione di listing degli attributi verificati posseduti da {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
    });

    const tenantId = getOrganizationId(tenantType);
    this.response = await apiClient.tenants.getVerifiedAttributes(
      tenantId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo verificato da {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      requiredVerifiedAttributes: z.array(z.array(z.string())),
      response: z.object({
        status: z.number(),
        data: z.object({
          attributes: z.array(
            z.object({
              id: z.string(),
              verifiedBy: z.array(
                z.object({
                  id: z.string(),
                })
              ),
            })
          ),
        }),
      }),
    });

    assert.equal(this.response.status, 200);

    const verifierId = getOrganizationId(tenantType);
    const attributeId = this.requiredVerifiedAttributes[0][0];
    assert.ok(
      this.response.data.attributes.some(
        (a) =>
          a.id === attributeId && a.verifiedBy.some((v) => v.id === verifierId),
        "L'attributo verificato non è presente nella lista degli attributi verificati"
      )
    );
  }
);
