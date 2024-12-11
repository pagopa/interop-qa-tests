import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { AgreementState, VerifiedTenantAttribute } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

When(
  "l'utente revoca l'attributo precedentemente verificato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      consumerId: z.string(),
      attributeId: z.string(),
      agreementId: z.string(),
    });
    this.response = await apiClient.tenants.revokeVerifiedAttribute(
      this.consumerId,
      this.attributeId,
      { agreementId: this.agreementId },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "l'attributo di {string} rimane verificato da {string}",
  async function (tenantType: TenantType, tenantTypeVerifier: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });

    let attribute: VerifiedTenantAttribute | undefined;
    const consumer = getOrganizationId(tenantType);
    const verifier = getOrganizationId(tenantTypeVerifier);

    await makePolling(
      () =>
        apiClient.tenants.getVerifiedAttributes(
          consumer,
          getAuthorizationHeader(this.token)
        ),
      (res) => {
        attribute = res.data.attributes.find((a) => a.id === this.attributeId);
        return attribute?.revokedBy.length !== 0;
      }
    );
    assert.ok(
      attribute?.verifiedBy.some((t) => t.id === verifier),
      `L'attributo non è verificato da ${tenantTypeVerifier}`
    );
  }
);

Then(
  "l'attributo di {string} risulta revocato da {string}",
  async function (tenantType: TenantType, tenantTypeRevoker: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      attributeId: z.string(),
    });

    let attribute: VerifiedTenantAttribute | undefined;
    const consumer = getOrganizationId(tenantType);
    const revoker = getOrganizationId(tenantTypeRevoker);

    await makePolling(
      () =>
        apiClient.tenants.getVerifiedAttributes(
          consumer,
          getAuthorizationHeader(this.token)
        ),
      (res) => {
        attribute = res.data.attributes.find((a) => a.id === this.attributeId);
        return attribute?.revokedBy.length !== 0;
      }
    );
    assert.ok(
      attribute?.revokedBy.some((t) => t.id === revoker),
      `L'attributo non è revocato da ${tenantTypeRevoker}`
    );
  }
);

Given(
  "{string} ha un'altra richiesta di fruizione in stato {string} per quell'e-service",
  async function (consumer: TenantType, agreementState: AgreementState) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      token: z.string(),
    });
    const token = await getToken(consumer);
    this.otherAgreementId =
      await dataPreparationService.createAgreementWithGivenState(
        token,
        agreementState,
        this.eserviceId,
        this.descriptorId
      );
  }
);

Given(
  "{string} ha già verificato l'attributo verificato a {string} sull'altra richiesta di fruizione",
  async function (verifier: TenantType, consumer: TenantType) {
    assertContextSchema(this, {
      attributeId: z.string(),
      otherAgreementId: z.string(),
    });

    const token = await getToken(verifier);
    this.consumerId = getOrganizationId(consumer);
    const verifierId = getOrganizationId(verifier);

    await dataPreparationService.assignVerifiedAttributeToTenant({
      token,
      tenantId: this.consumerId,
      agreementId: this.otherAgreementId,
      verifierId,
      attributeId: this.attributeId,
    });
  }
);
