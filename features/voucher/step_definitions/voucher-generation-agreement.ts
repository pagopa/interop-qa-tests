import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  TenantType,
  assertContextSchema,
  getOrganizationId,
  getToken,
} from "../../../utils/commons";
import { AttributeKind } from "../../../api/models";

Given(
  "{string} ha già attivato nuovamente quella richiesta di fruizione come {string}",
  async function (
    tenantType: TenantType,
    reactivatedBy: "PRODUCER" | "CONSUMER"
  ) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenantType);
    await dataPreparationService.activateAgreement(
      token,
      this.agreementId,
      reactivatedBy
    );
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
    const revokerId = getOrganizationId(ente);
    const tenantId = getOrganizationId(tenantType);
    switch (attributeKind) {
      case "CERTIFIED":
        await dataPreparationService.revokeCertifiedAttributeToTenant(
          token,
          tenantId,
          this.attributeId
        );
        break;
      case "VERIFIED":
        await dataPreparationService.revokeVerifiedAttributeToTenant(
          token,
          tenantId,
          this.attributeId,
          revokerId
        );
        break;
      case "DECLARED":
        await dataPreparationService.revokeDeclaredAttributeToTenant(
          token,
          tenantId,
          this.attributeId
        );
        break;
    }
  }
);

Given(
  "{string} ha già aggiornato la richiesta di fruizione all'ultima versione dell'eservice",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenantType);

    this.agreementId = await dataPreparationService.upgradeAgreement(
      token,
      this.agreementId
    );
  }
);

Given(
  "{string} ha già archiviato quella richiesta di fruizione",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenantType);

    this.response = await dataPreparationService.archiveAgreement(
      token,
      this.agreementId
    );
  }
);

Given(
  "{string} ha già pubblicato una nuova versione per quell'e-service che richiede quell'attributo verificato",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      attributeId: z.string(),
    });
    const token = await getToken(tenantType);

    this.descriptorId = await dataPreparationService.createNextDraftDescriptor(
      token,
      this.eserviceId
    );

    await dataPreparationService.updateDraftDescriptor({
      token,
      eserviceId: this.eserviceId,
      descriptorId: this.descriptorId,
      partialDescriptorSeed: {
        attributes: {
          certified: [],
          declared: [],
          verified: [
            [{ id: this.attributeId, explicitAttributeVerification: true }],
          ],
        },
      },
    });

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId: this.eserviceId,
      descriptorId: this.descriptorId,
      descriptorState: "PUBLISHED",
    });
  }
);

Given(
  "{string} approva quella richiesta di fruizione",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);
