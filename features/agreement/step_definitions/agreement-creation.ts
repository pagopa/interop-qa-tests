import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Role, TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  AgreementApprovalPolicy,
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
