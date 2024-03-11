import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { Role, TenantType } from "../../common-steps";
import {
  AgreementApprovalPolicy,
  EServiceDescriptorState,
} from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "un {string} di {string} ha già creato un e-service in stato {string} con approvazione {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this);
    const token = getToken(this.tokens, tenantType, role);
    this.eserviceId = await dataPreparationService.createEService(token);
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
        agreementApprovalPolicy,
      });
    this.descriptorId = response.descriptorId;
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione limitata ai primi {int}",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementProducers(
      { limit, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementProducers(
      { limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.responseOffsetOne = await apiClient.agreements.getAgreementProducers(
      { limit: 50, offset },
      getAuthorizationHeader(this.token)
    );

    this.responseOffsetTwo = await apiClient.agreements.getAgreementProducers(
      { limit: 50, offset: offset + 1 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori degli e-service per cui ha una richiesta di fruizione filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementProducers(
      { q: encodeURIComponent(keyword), limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} erogator(i)(e)",
  async function (statusCode: number, consumers: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });

    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, consumers);
  }
);

Then(
  "si ottiene status code 200 con la corretta verifica dell'offset",
  async function () {
    assertContextSchema(this, {
      responseOffsetOne: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(
            z.object({
              id: z.string(),
            })
          ),
        }),
      }),
      responseOffsetTwo: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(
            z.object({
              id: z.string(),
            })
          ),
        }),
      }),
    });

    assert.equal(this.responseOffsetOne.status, 200);
    assert.equal(this.responseOffsetTwo.status, 200);

    assert.equal(
      this.responseOffsetOne.data.results[1].id,
      this.responseOffsetTwo.data.results[0].id
    );
  }
);
