import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getRandomInt,
  getRiskAnalysis,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Role, TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";

When(
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
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
  "l'utente ha già creato una finalità in stato {string} per quell'eservice",
  async function (purposeState) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    const consumerId = getOrganizationId(this.tenantType);

    await dataPreparationService.createPurpose(
      this.token,
      purposeState,
      this.TEST_SEED,
      {
        eserviceId: this.eserviceId,
        consumerId,
      }
    );
  }
);

Given(
  "un {string} di {string} ha già sospeso quell'e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);
    await dataPreparationService.suspendDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, in modalità gratuita senza specificare una ragione",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
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
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, con un'analisi del rischio parzialmente compilata ma formattata correttamente",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: 5,
        riskAnalysisForm: getRiskAnalysis({
          tenantType: "PA1",
          completed: false,
        }).riskAnalysisForm,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati, con un'analisi del rischio parzialmente compilata, formattata correttamente, ma con un template datato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
    });

    const consumerId = getOrganizationId(this.tenantType);
    const { riskAnalysisForm } = getRiskAnalysis({
      completed: false,
      tenantType: this.tenantType,
    });

    const outdatedVersion = "1.0";

    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: 5,
        riskAnalysisForm: {
          ...riskAnalysisForm,
          version: outdatedVersion,
        },
      },
      getAuthorizationHeader(this.token)
    );
  }
);
