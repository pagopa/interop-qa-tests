import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Role, TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  AgreementApprovalPolicy,
  AgreementState,
  EServiceDescriptorState,
} from "../../../api/models";

Given(
  "{string} possiede un attributo certificato",
  async function (tenantType: TenantType) {
    assertContextSchema(this);
    const tenantId = getOrganizationId(tenantType);

    const response = await apiClient.tenants.getCertifiedAttributes(
      tenantId,
      getAuthorizationHeader(this.token)
    );
    const { attributes } = response.data;

    const notRevokedAttributes = attributes.filter(
      (attr) => !attr.revocationTimestamp
    );

    if (notRevokedAttributes.length === 0) {
      throw new Error(`No certified attributes found for ${tenantType}`);
    }

    this.attributeId = notRevokedAttributes[0].id;
  }
);

Given(
  "un {string} di {string} ha già creato un e-service in stato {string} che richiede quell'attributo certificato con approvazione {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this, { attributeId: z.string() });
    const token = getToken(this.tokens, tenantType, role);
    this.eserviceId = await dataPreparationService.createEService(token);
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
        attributes: {
          certified: [
            [{ id: this.attributeId, explicitAttributeVerification: true }],
          ],
          declared: [],
          verified: [],
        },
        agreementApprovalPolicy,
      });
    this.descriptorId = response.descriptorId;
  }
);

Given(
  "un {string} di {string} ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, role);
    this.agreementId = await dataPreparationService.createAgreement(
      token,
      this.eserviceId,
      this.descriptorId
    );
    await dataPreparationService.submitAgreement(
      token,
      this.agreementId,
      "PENDING"
    );
  }
);

Given(
  "un {string} di {string} ha già rifiutato quella richiesta di fruizione",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, role);
    await dataPreparationService.rejectAgreement(token, this.agreementId);
  }
);

Given(
  "{string} ha una richiesta di fruizione in stato {string} per quell'e-service",
  async function (consumer: TenantType, agreementState: string) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      token: z.string(),
    });
    const token = getToken(this.tokens, consumer, "admin");
    this.agreementId =
      await dataPreparationService.createAgreementWithGivenState(
        token,
        agreementState,
        this.eserviceId,
        this.descriptorId
      );
  }
);

Given(
  "{string} non possiede uno specifico attributo certificato",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
    });
    const tenantId = getOrganizationId(tenantType);

    const response = await apiClient.tenants.getCertifiedAttributes(
      tenantId,
      getAuthorizationHeader(this.token)
    );
    const { attributes } = response.data;
    const attributesSuperset = await apiClient.attributes.getAttributes(
      {
        limit: attributes.length + 1,
        offset: 0,
        kinds: ["CERTIFIED"],
      },
      getAuthorizationHeader(this.token)
    );

    const attributesIds = attributes.map((attr) => attr.id);
    const attributesSupersetIds = attributesSuperset.data.results.map(
      (attr) => attr.id
    );

    const missingAttributeId = attributesSupersetIds.find(
      (attrId) => !attributesIds.includes(attrId)
    );

    this.attributeId = missingAttributeId;
  }
);

Given(
  "{string} ha creato un attributo certificato e lo ha assegnato a {string}",
  async function (certifier: TenantType, tenantType: TenantType) {
    assertContextSchema(this, {});
    const token = getToken(this.tokens, certifier, "admin");

    const tenantId = getOrganizationId(tenantType);
    this.attributeId = await dataPreparationService.createAttribute(
      token,
      "CERTIFIED"
    );

    await dataPreparationService.assignCertifiedAttributeToTenant(
      token,
      tenantId,
      this.attributeId
    );
  }
);

Given(
  "{string} ha già revocato quell'attributo a {string}",
  async function (certifier: TenantType, tenantType: TenantType) {
    assertContextSchema(this, { attributeId: z.string() });
    const token = getToken(this.tokens, certifier, "admin");

    const tenantId = getOrganizationId(tenantType);

    await dataPreparationService.revokeCertifiedAttributeToTenant(
      token,
      tenantId,
      this.attributeId
    );
  }
);

Given(
  "la richiesta di fruizione è passata in stato {string}",
  async function (agreementState: AgreementState) {
    assertContextSchema(this, { agreementId: z.string(), token: z.string() });
    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.agreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.data.state === agreementState
    );
  }
);

Given(
  "un {string} di {string} ha già pubblicato una nuova versione per quell'e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, role);
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState: "PUBLISHED",
      });
    this.descriptorId = response.descriptorId;
  }
);

When(
  "l'utente crea una richiesta di fruizione in bozza per l'ultima versione di quell'e-service",
  async function () {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.agreements.createAgreement(
      {
        eserviceId: this.eserviceId,
        descriptorId: this.descriptorId,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente crea una richiesta di fruizione in bozza per la penultima versione di quell'e-service",
  async function () {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.agreements.createAgreement(
      {
        eserviceId: this.eserviceId,
        descriptorId: this.descriptorId,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
