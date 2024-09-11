import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { AttributeKind } from "../../../api/models";

Given(
  "{string} ha già attivato nuovamente quella richiesta di fruizione",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenantType);
    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);

Given(
  "{string} ha già (assegnato)(dichiarato) nuovamente quell'attributo {string} a {string}",
  async function (
    ente: TenantType,
    attributeKind: AttributeKind,
    tenantType: TenantType
  ) {
    assertContextSchema(this, { attributeId: z.string() });
    const tenantId = getOrganizationId(tenantType);
    const token = await getToken(ente);

    switch (attributeKind) {
      case "CERTIFIED":
        await dataPreparationService.assignCertifiedAttributeToTenant(
          token,
          tenantId,
          this.attributeId
        );
        break;
      case "VERIFIED":
        const verifierId = getOrganizationId(ente);
        await dataPreparationService.assignVerifiedAttributeToTenant(
          token,
          tenantId,
          verifierId,
          this.attributeId
        );
        break;
      case "DECLARED":
        await dataPreparationService.declareDeclaredAttribute(
          token,
          tenantId,
          this.attributeId
        );
        break;

      default:
        break;
    }
  }
);

Given(
  "{string} ha già revocato quell'attributo {string} a {string}",
  async function (
    ente: TenantType,
    attributeKind: AttributeKind,
    tenantType: TenantType
  ) {
    assertContextSchema(this, { attributeId: z.string() });
    const token = await getToken(ente);
    const tenantId = getOrganizationId(tenantType);

    await dataPreparationService.revokeTenantAttribute(
      token,
      attributeKind,
      tenantId,
      this.attributeId
    );
  }
);

Given(
  "la richiesta di fruizione è stata aggiornata all'ultima versione dell'eservice",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      agreementId: z.string(),
    });

    await apiClient.agreements.upgradeAgreement(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "{string} ha già pubblicato una nuova versione per quell'e-service con approvazione manuale",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = await getToken(tenantType);

    const descriptorId = await dataPreparationService.createNextDraftDescriptor(
      token,
      this.eserviceId
    );

    await dataPreparationService.updateDraftDescriptor({
      token,
      eserviceId: this.eserviceId,
      descriptorId,
      partialDescriptorSeed: { agreementApprovalPolicy: "MANUAL" },
    });

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId: this.eserviceId,
      descriptorId,
      descriptorState: "PUBLISHED",
    });

    this.nextDescriptorId = descriptorId;
  }
);

Given(
  "la richiesta di fruizione è stata aggiornata all'ultima versione dell'eservice ed è in stato {string}",
  async function (state: "ACTIVE" | "PENDING" | undefined) {
    assertContextSchema(this, {
      token: z.string(),
      agreementId: z.string(),
    });

    await apiClient.agreements.upgradeAgreement(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );

    await dataPreparationService.submitAgreement(
      this.token,
      this.agreementId,
      state
    );
  }
);
