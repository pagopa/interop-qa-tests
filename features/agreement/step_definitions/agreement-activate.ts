import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getOrganizationId,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { TenantType } from "../../common-steps";
import {
  EServiceDescriptorState,
  AgreementApprovalPolicy,
} from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} crea un attributo verificato",
  async function (consumer: TenantType) {
    assertContextSchema(this);

    const token = getToken(this.tokens, consumer, "admin");

    const attributeId = await dataPreparationService.createAttribute(
      token,
      "VERIFIED"
    );

    this.requiredVerifiedAttributes = [[attributeId]];
  }
);

Given(
  "{string} verifica l'attributo verificato a {string}",
  async function (verifier: TenantType, consumer: TenantType) {
    assertContextSchema(this, {
      requiredVerifiedAttributes: z.array(z.array(z.string())),
    });

    const token = getToken(this.tokens, verifier, "admin");
    const consumerId = getOrganizationId(consumer);
    const verifierId = getOrganizationId(verifier);

    const attributeId = this.requiredVerifiedAttributes[0][0];

    await dataPreparationService.assignVerifiedAttributeToTenant(
      token,
      consumerId,
      verifierId,
      attributeId
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

    const token = getToken(this.tokens, tenantType, "admin");
    this.eserviceId = await dataPreparationService.createEService(token);
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
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
      });
    this.descriptorId = response.descriptorId;
  }
);

Given(
  "{string} ha già sospeso quella richiesta di fruizione come {string}",
  async function (tenant: TenantType, suspendedBy: "PRODUCER" | "CONSUMER") {
    assertContextSchema(this, {
      agreementId: z.string(),
    });

    const token = getToken(this.tokens, tenant, "admin");
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

    const token = getToken(this.tokens, tenantType, "admin");

    await dataPreparationService.activateAgreement(token, this.agreementId);
  }
);

Given(
  "due gruppi di due attributi certificati da {string}, dei quali {string} ne possiede uno per gruppo",
  async function (certifier: TenantType, consumer: TenantType) {
    assertContextSchema(this);
    const consumerId = getOrganizationId(consumer);
    const certifierToken = getToken(this.tokens, certifier, "admin");

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
    assertContextSchema(this);
    const token = getToken(this.tokens, tenant, "admin");

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
    assertContextSchema(this);
    const tenantId = getOrganizationId(tenant);
    const token = getToken(this.tokens, tenant, "admin");

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
    const verifierToken = getToken(this.tokens, verifier, "admin");
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
