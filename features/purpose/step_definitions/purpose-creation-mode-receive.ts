import { randomUUID } from "crypto";
import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { Role, TenantType } from "../../common-steps";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getRandomInt,
  getRiskAnalysis,
  getToken,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import {
  AgreementApprovalPolicy,
  PurposeVersionState,
} from "../../../api/models";

Given(
  "un {string} di {string} ha già creato un'analisi del rischio per quell'e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);

    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        token,
        this.eserviceId,
        getRiskAnalysis({ completed: true, tenantType })
      );
  }
);

Given(
  "un {string} di {string} ha già pubblicato quella versione di e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);

    await dataPreparationService.publishDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

When(
  "l'utente crea una nuova finalità con tutti i campi richiesti correttamente formattati per quell'e-service associando quella analisi del rischio creata dall'erogatore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
    });

    const consumerId = getOrganizationId(this.tenantType);

    this.response = await apiClient.reverse.createPurposeForReceiveEservice(
      {
        eserviceId: this.eserviceId,
        consumerId,
        riskAnalysisId: this.riskAnalysisId,
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: 5,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "un {string} di {string} ha già creato una finalità in stato {string} per quell'eservice associando quell'analisi del rischio creata dall'erogatore",
  async function (
    role: Role,
    tenantType: TenantType,
    purposeState: PurposeVersionState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);
    const consumerId = getOrganizationId(tenantType);

    this.purposeId = await dataPreparationService.createPurposeWithGivenState({
      token,
      testSeed: this.TEST_SEED,
      payload: {
        eserviceId: this.eserviceId,
        consumerId,
        riskAnalysisId: this.riskAnalysisId,
      },
      purposeState,
      eserviceMode: "RECEIVE",
    });
  }
);

Given(
  "un {string} di {string} ha già creato un e-service in modalità RECEIVE in stato DRAFT che richiede quell'attributo certificato con approvazione {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    approvalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this, {
      attributeId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, role);
    this.eserviceId = await dataPreparationService.createEService(token, {
      mode: "RECEIVE",
    });

    this.descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      this.eserviceId,
      {
        agreementApprovalPolicy: approvalPolicy,
        attributes: {
          certified: [
            [
              {
                id: this.attributeId,
                explicitAttributeVerification: true,
              },
            ],
          ],
          declared: [],
          verified: [],
        },
      }
    );
  }
);

Given(
  "un {string} di {string} ha già creato un e-service in stato DRAFT in modalità RECEIVE con approvazione {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    approvalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this);
    const token = getToken(this.tokens, tenantType, role);
    this.eserviceId = await dataPreparationService.createEService(token, {
      mode: "RECEIVE",
    });

    this.descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      this.eserviceId,
      {
        agreementApprovalPolicy: approvalPolicy,
      }
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service associando quella analisi del rischio creata dall'erogatore con tutti i campi richiesti correttamente formattati, in modalità gratuita senza specificare una ragione",
  async function () {
    const consumerId = getOrganizationId(this.tenantType);

    this.response = await apiClient.reverse.createPurposeForReceiveEservice(
      {
        eserviceId: this.eserviceId,
        consumerId,
        riskAnalysisId: this.riskAnalysisId,
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: undefined,
        dailyCalls: 5,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati senza passare l'identificativo dell'analisi del rischio",
  async function () {
    const consumerId = getOrganizationId(this.tenantType);

    this.response = await apiClient.reverse.createPurposeForReceiveEservice(
      {
        eserviceId: this.eserviceId,
        consumerId,
        riskAnalysisId: "",
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: 5,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service associando una analisi del rischio diversa da quelle create dall'erogatore",
  async function () {
    const consumerId = getOrganizationId(this.tenantType);

    this.response = await apiClient.reverse.createPurposeForReceiveEservice(
      {
        eserviceId: this.eserviceId,
        consumerId,
        riskAnalysisId: randomUUID(),
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: 5,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
