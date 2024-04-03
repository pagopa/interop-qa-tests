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
import { TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  AgreementApprovalPolicy,
  AgreementState,
  EServiceDescriptorState,
} from "../../../api/models";

Given(
  "{string} ha già creato un e-service in stato {string} che richiede quell'attributo certificato con approvazione {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this, { attributeId: z.string() });
    const token = getToken(this.tokens, tenantType);
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
  "{string} ha già creato e inviato una richiesta di fruizione per quell'e-service ed è in attesa di approvazione",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const token = getToken(this.tokens, tenantType);
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
  "{string} ha già rifiutato quella richiesta di fruizione",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      agreementId: z.string(),
    });
    const token = getToken(this.tokens, tenantType);
    await dataPreparationService.rejectAgreement(token, this.agreementId);
  }
);

Given(
  "{string} ha creato un attributo certificato e non lo ha assegnato a {string}",
  async function (certifier: TenantType, _tenantType: TenantType) {
    assertContextSchema(this);
    const token = getToken(this.tokens, certifier);

    this.attributeId = await dataPreparationService.createAttribute(
      token,
      "CERTIFIED"
    );
  }
);

Given(
  "{string} ha già revocato quell'attributo a {string}",
  async function (certifier: TenantType, tenantType: TenantType) {
    assertContextSchema(this, { attributeId: z.string() });
    const token = getToken(this.tokens, certifier);

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
  "{string} ha già pubblicato una nuova versione per quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = getToken(this.tokens, tenantType);
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
  "l'utente crea una richiesta di fruizione in bozza per (la penultima)(l'ultima) versione di quell'e-service",
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
