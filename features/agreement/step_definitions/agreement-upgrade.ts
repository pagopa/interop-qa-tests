import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { AttributeKind, DescriptorAttributeSeed } from "../../../api/models";

When(
  "l'utente richiede un'operazione di upgrade di quella richiesta di fruizione",
  async function () {
    assertContextSchema(this, { token: z.string(), agreementId: z.string() });

    const response = await apiClient.agreements.upgradeAgreement(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );
    this.responseAgreementId = response.data.id;
    this.response = response;
  }
);

Given(
  "{string} ha già pubblicato una nuova versione per quell'e-service richiedendo gli stessi attributi certificati",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      attributeId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, "admin");
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState: "PUBLISHED",
        attributes: {
          certified: [
            [{ id: this.attributeId, explicitAttributeVerification: true }],
          ],
          declared: [],
          verified: [],
        },
      });
    this.descriptorId = response.descriptorId;
  }
);

Given(
  "{string} ha già pubblicato una nuova versione per quell'e-service che richiede un attributo {string} che {string} non possiede",
  async function (
    tenantType: TenantType,
    kind: AttributeKind,
    _consumer: TenantType
  ) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, "admin");

    const attributeId = await dataPreparationService.createAttribute(
      token,
      kind
    );

    const seed: DescriptorAttributeSeed[][] = [
      [{ id: attributeId, explicitAttributeVerification: true }],
    ];

    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState: "PUBLISHED",
        attributes: {
          certified: kind === "CERTIFIED" ? seed : [],
          declared: kind === "DECLARED" ? seed : [],
          verified: kind === "VERIFIED" ? seed : [],
        },
      });
    this.descriptorId = response.descriptorId;
  }
);

Then(
  "si ottiene status code {int} ed è stata creata una nuova richiesta di fruizione in DRAFT",
  async function (statusCode: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
      }),
      responseAgreementId: z.string(),
    });

    assert.equal(this.response.status, statusCode);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.responseAgreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.status !== 404
    );

    const createdAgreement = await apiClient.agreements.getAgreementById(
      this.responseAgreementId,
      getAuthorizationHeader(this.token)
    );
    assert.equal(createdAgreement.data.state, "DRAFT");
  }
);

Then(
  "si ottiene status code 200 e la nuova richiesta di fruizione è associata alla versione 3 dell'eservice",
  async function () {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
      }),
      responseAgreementId: z.string(),
      descriptorId: z.string(),
    });

    assert.equal(this.response.status, 200);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.responseAgreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.status !== 404
    );

    const createdAgreement = await apiClient.agreements.getAgreementById(
      this.responseAgreementId,
      getAuthorizationHeader(this.token)
    );
    assert.equal(createdAgreement.data.descriptorId, this.descriptorId);
  }
);
