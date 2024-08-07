import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { VerifiedTenantAttribute } from "../../../api/models";

When(
  "l'utente revoca l'attributo precedentemente verificato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      consumerId: z.string(),
      attributeId: z.string(),
    });
    this.response = await apiClient.tenants.revokeVerifiedAttribute(
      this.consumerId,
      this.attributeId,
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
