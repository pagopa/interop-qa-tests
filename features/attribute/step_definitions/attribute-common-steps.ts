import assert from "assert";
import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { assertContextSchema, getToken } from "../../../utils/commons";
import { TenantType } from "../../../utils/commons";
import { AttributeKind } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già creato un attributo {string} con nome che contiene {string}",
  async function (
    tenantType: TenantType,
    attributeKind: AttributeKind,
    keyword: string
  ) {
    assertContextSchema(this);
    const token = await getToken(tenantType);
    await dataPreparationService.createAttribute(
      token,
      attributeKind,
      `${this.TEST_SEED}-${keyword}`
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} attribut(i)(o)",
  function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, count);
  }
);
