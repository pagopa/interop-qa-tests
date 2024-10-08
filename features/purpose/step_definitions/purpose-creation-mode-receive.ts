import { randomUUID } from "crypto";
import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { TenantType } from "../../../utils/commons";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getRandomInt,
  getToken,
} from "../../../utils/commons";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import { AgreementApprovalPolicy } from "../../../api/models";

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
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "{string} ha già creato un e-service in modalità RECEIVE in stato DRAFT che richiede quell'attributo certificato con approvazione {string}",
  async function (
    tenantType: TenantType,
    approvalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this, {
      attributeId: z.string(),
    });
    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        {
          mode: "RECEIVE",
        },
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

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);

Given(
  "{string} ha già creato un e-service in stato DRAFT in modalità RECEIVE con approvazione {string}",
  async function (
    tenantType: TenantType,
    approvalPolicy: AgreementApprovalPolicy
  ) {
    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        {
          mode: "RECEIVE",
        },
        {
          agreementApprovalPolicy: approvalPolicy,
        }
      );

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service associando quella analisi del rischio creata dall'erogatore con tutti i campi richiesti correttamente formattati, in modalità gratuita senza specificare una ragione",
  async function () {
    assertContextSchema(this);

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
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati senza passare l'identificativo dell'analisi del rischio",
  async function () {
    assertContextSchema(this);
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
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service associando una analisi del rischio diversa da quelle create dall'erogatore",
  async function () {
    assertContextSchema(this);
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
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
