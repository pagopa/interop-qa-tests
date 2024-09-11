import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getOrganizationId,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { TenantType } from "../../../utils/commons";
import {
  EServiceDescriptorState,
  AgreementApprovalPolicy,
} from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già creato un attributo verificato",
  async function (consumer: TenantType) {
    const token = await getToken(consumer);

    console.log("1)tenantId: ", getOrganizationId(consumer));

    this.attributeId = await dataPreparationService.createAttribute(
      token,
      "VERIFIED"
    );

    this.requiredVerifiedAttributes = [[this.attributeId]];
  }
);

Given(
  "{string} ha già verificato l'attributo verificato a {string}",
  async function (verifier: TenantType, consumer: TenantType) {
    assertContextSchema(this, {
      attributeId: z.string(),
    });

    const token = await getToken(verifier);
    this.consumerId = getOrganizationId(consumer);
    const verifierId = getOrganizationId(verifier);

    await dataPreparationService.assignVerifiedAttributeToTenant(
      token,
      this.consumerId,
      verifierId,
      this.attributeId
    );
  }
);

Given(
  "{string} ha già creato un e-service in stato {string} che richiede quegli attributi con approvazione {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this, {
      requiredCertifiedAttributes: z.array(z.array(z.string())).optional(),
      requiredDeclaredAttributes: z.array(z.array(z.string())).optional(),
      requiredVerifiedAttributes: z.array(z.array(z.string())).optional(),
    });

    const requiredCertifiedAttributes = this.requiredCertifiedAttributes ?? [];
    const requiredDeclaredAttributes = this.requiredDeclaredAttributes ?? [];
    const requiredVerifiedAttributes = this.requiredVerifiedAttributes ?? [];

    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        {},
        {
          attributes: {
            certified: requiredCertifiedAttributes.map((group) =>
              group.map((attrId) => ({
                id: attrId,
                explicitAttributeVerification: true,
              }))
            ),
            declared: requiredDeclaredAttributes.map((group) =>
              group.map((attrId) => ({
                id: attrId,
                explicitAttributeVerification: true,
              }))
            ),
            verified: requiredVerifiedAttributes.map((group) =>
              group.map((attrId) => ({
                id: attrId,
                explicitAttributeVerification: true,
              }))
            ),
          },
          agreementApprovalPolicy,
        }
      );

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId,
      descriptorId,
      descriptorState,
    });

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);

Given(
  "{string} ha già sospeso quella richiesta di fruizione come {string}",
  async function (tenant: TenantType, suspendedBy: "PRODUCER" | "CONSUMER") {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenant);
    await dataPreparationService.suspendAgreement(
      token,
      this.agreementId,
      suspendedBy
    );
  }
);

Given(
  "{string} ha già approvato quella richiesta di fruizione",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);

Given(
  "due gruppi di due attributi certificati da {string}, dei quali {string} ne possiede uno per gruppo",
  async function (certifier: TenantType, consumer: TenantType) {
    const consumerId = getOrganizationId(consumer);
    const certifierToken = await getToken(certifier);

    const requiredCertifiedAttributes: string[][] = [];

    for (let groupIdx = 0; groupIdx < 2; groupIdx++) {
      requiredCertifiedAttributes.push([]);
      for (let attrIdx = 0; attrIdx < 2; attrIdx++) {
        const attributeId = await dataPreparationService.createAttribute(
          certifierToken,
          "CERTIFIED"
        );

        // Assign only one attribute in the attribute group
        if (attrIdx % 2 === 0) {
          await dataPreparationService.assignCertifiedAttributeToTenant(
            certifierToken,
            consumerId,
            attributeId
          );
        }
        requiredCertifiedAttributes[groupIdx].push(attributeId);
      }
    }

    this.requiredCertifiedAttributes = requiredCertifiedAttributes;
  }
);

Given(
  "{string} crea due gruppi di due attributi verificati",
  async function (tenant: TenantType) {
    const token = await getToken(tenant);

    const requiredVerifiedAttributes: string[][] = [];

    for (let groupIdx = 0; groupIdx < 2; groupIdx++) {
      requiredVerifiedAttributes.push([]);
      for (let attrIdx = 0; attrIdx < 2; attrIdx++) {
        const attributeId = await dataPreparationService.createAttribute(
          token,
          "VERIFIED"
        );
        requiredVerifiedAttributes[groupIdx].push(attributeId);
      }
    }

    this.requiredVerifiedAttributes = requiredVerifiedAttributes;
  }
);

Given(
  "due gruppi di due attributi dichiarati, dei quali {string} ne possiede uno per gruppo",
  async function (tenant: TenantType) {
    const tenantId = getOrganizationId(tenant);
    const token = await getToken(tenant);

    const requiredDeclaredAttributes: string[][] = [];

    for (let groupIdx = 0; groupIdx < 2; groupIdx++) {
      requiredDeclaredAttributes.push([]);
      for (let attrIdx = 0; attrIdx < 2; attrIdx++) {
        const attributeId = await dataPreparationService.createAttribute(
          token,
          "DECLARED"
        );

        // Assign only one attribute in the attribute group
        if (attrIdx % 2 === 0) {
          await dataPreparationService.declareDeclaredAttribute(
            token,
            tenantId,
            attributeId
          );
        }
        requiredDeclaredAttributes[groupIdx].push(attributeId);
      }
    }

    this.requiredDeclaredAttributes = requiredDeclaredAttributes;
  }
);

Given(
  "{string} verifica un attributo per ogni gruppo di attributi verificati a {string}",
  async function (verifier: TenantType, consumer: TenantType) {
    assertContextSchema(this, {
      requiredVerifiedAttributes: z.array(z.array(z.string())),
    });
    const verifierToken = await getToken(verifier);
    const verifierId = getOrganizationId(verifier);
    const consumerId = getOrganizationId(consumer);

    const attributeIdsToVerify = this.requiredVerifiedAttributes.map(
      (group) => group[0]
    );

    for (const attributeId of attributeIdsToVerify) {
      await dataPreparationService.assignVerifiedAttributeToTenant(
        verifierToken,
        consumerId,
        verifierId,
        attributeId
      );
    }
  }
);

When(
  "l'utente richiede una operazione di attivazione di quella richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      agreementId: z.string(),
    });

    this.response = await apiClient.agreements.activateAgreement(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );
  }
);
