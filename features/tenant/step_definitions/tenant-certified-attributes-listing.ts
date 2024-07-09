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
  "l'utente richiede una operazione di listing degli attributi certificati posseduti da {string}",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
    });

    const tenantId = getOrganizationId(tenantType);

    this.response = await apiClient.tenants.getCertifiedAttributes(
      tenantId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi certificati contenente l'attributo assegnato e l'attributo IPA \"Comune\"",
  async function () {
    assertContextSchema(this, {
      attributeId: z.string(),
      response: z.object({
        status: z.number(),
        data: z.object({
          attributes: z.array(
            z.object({
              id: z.string(),
              name: z.string(),
            })
          ),
        }),
      }),
    });

    assert.equal(this.response.status, 200);
    assert.ok(
      this.response.data.attributes.some(
        (attr) => attr.id === this.attributeId
      ),
      "L'attributo assegnato non è presente nella lista degli attributi certificati"
    );
    assert.ok(
      this.response.data.attributes.some(
        (attr) => attr.name === "Comuni e loro Consorzi e Associazioni"
      ),
      "L'attributo IPA comune non è presente nella lista degli attributi certificati"
    );
  }
);
