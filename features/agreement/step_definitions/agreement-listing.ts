import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType, SessionTokens, Role } from "../../common-steps";

Given(
  "un {string} di {string} ha già creato {int} e-service(s) in stato PUBLISHED",
  async function (role: Role, tenantType: TenantType, numberEServices: number) {
    assertContextSchema(this);
    const token = getToken(this.tokens, tenantType, role);

    const publishedEservicesIds: Array<[string, string]> = [];
    for (let i = 0; i < numberEServices; i++) {
      const eserviceId = await dataPreparationService.createEService(token);
      const { descriptorId } =
        await dataPreparationService.createDescriptorWithGivenState({
          token,
          eserviceId,
          descriptorState: "PUBLISHED",
        });

      publishedEservicesIds.push([eserviceId, descriptorId]);
    }

    this.publishedEservicesIds = publishedEservicesIds;
  }
);

Given(
  "{string} ha un agreement attivo per ciascun e-service di {string}",
  async function (consumer: TenantType, _producer: string) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
      tokens: SessionTokens,
    });
    const token = getToken(this.tokens, consumer, "admin");

    for (const [eserviceId, descriptorId] of this.publishedEservicesIds) {
      const agreementId = await dataPreparationService.createAgreement(
        token,
        eserviceId,
        descriptorId
      );

      await dataPreparationService.submitAgreement(token, agreementId);
    }
  }
);

When(
  "l'utente richiede una operazione di listing limitata alle prime {int} richieste di fruizione",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
      publishedEservicesIds: z.array(z.tuple([z.string(), z.string()])),
    });
    const eservicesIds = this.publishedEservicesIds.map((p) => p[0]);
    this.response = await apiClient.agreements.getAgreements(
      {
        eservicesIds,
        limit,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} richiest(e)(a) di fruizione",
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
