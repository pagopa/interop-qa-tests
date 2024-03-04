import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getOrganizationId,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { Role, TenantType } from "../../common-steps";
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
  "{string} possiede un attributo dichiarato",
  async function (tenantType: TenantType) {
    assertContextSchema(this);
    const tenantId = getOrganizationId(tenantType);
    const token = getToken(this.tokens, tenantType, "admin");

    const response = await apiClient.tenants.getDeclaredAttributes(
      tenantId,
      getAuthorizationHeader(token)
    );
    const { attributes } = response.data;

    const declaredAttributes = attributes.filter(
      (attr) => !attr.revocationTimestamp
    );

    if (declaredAttributes.length === 0) {
      throw new Error(`No declared attributes found for ${tenantType}`);
    }

    this.requiredDeclaredAttributes = [[declaredAttributes[0].id]];
  }
);

Given(
  "un {string} di {string} ha già creato un e-service in stato {string} che richiede quegli attributi con approvazione {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this, {
      requiredCertifiedAttributes: z.array(z.array(z.string())),
      requiredDeclaredAttributes: z.array(z.array(z.string())),
      requiredVerifiedAttributes: z.array(z.array(z.string())),
    });

    const token = getToken(this.tokens, tenantType, role);
    this.eserviceId = await dataPreparationService.createEService(token);
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
        attributes: {
          certified: this.requiredCertifiedAttributes.map((group) =>
            group.map((attrId) => ({
              id: attrId,
              explicitAttributeVerification: true,
            }))
          ),
          declared: this.requiredDeclaredAttributes.map((group) =>
            group.map((attrId) => ({
              id: attrId,
              explicitAttributeVerification: true,
            }))
          ),
          verified: this.requiredVerifiedAttributes.map((group) =>
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
