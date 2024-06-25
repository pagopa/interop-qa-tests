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
  "l'utente richiede una operazione di listing degli attributi dichiarati posseduti da {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this);
    const tenantId = getOrganizationId(tenantType);
    this.response = await apiClient.tenants.getDeclaredAttributes(
      tenantId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo dichiarato",
  async function () {
    assertContextSchema(this, {
      requiredDeclaredAttributes: z.array(z.array(z.string())),
      response: z.object({
        status: z.number(),
        data: z.object({
          attributes: z.array(
            z.object({
              id: z.string(),
            })
          ),
        }),
      }),
    });

    assert.equal(this.response.status, 200);
    assert.ok(
      this.response.data.attributes.some(
        (a) => a.id === this.requiredDeclaredAttributes[0][0]
      ),
      "L'attributo dichiarato non è presente nella lista degli attributi dichiarati"
    );
  }
);
