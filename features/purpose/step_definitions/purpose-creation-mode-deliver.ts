import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getRandomInt,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../common-steps";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";

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
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "{string} ha già creato una finalità per quell'e-service con tutti i campi richiesti correttamente formattati",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);

    const title = `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`;
    const { purposeId } =
      await dataPreparationService.createPurposeWithGivenState({
        token,
        testSeed: this.TEST_SEED,
        eserviceMode: "DELIVER",
        payload: {
          title,
          eserviceId: this.eserviceId,
          consumerId,
        },
        purposeState: "DRAFT",
      });
    this.purposeId = purposeId;
    this.purposeTitle = title;
  }
);

When(
  "l'utente crea una nuova finalità per quell'e-service con tutti i campi richiesti correttamente formattati e lo stesso nome della precedente",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      tenantType: TenantType,
      purposeTitle: z.string(),
    });

    const consumerId = getOrganizationId(this.tenantType);
    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
        title: this.purposeTitle,
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
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
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
    const { riskAnalysisForm } = await dataPreparationService.getRiskAnalysis({
      completed: false,
      tenantType: "PA1",
    });

    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
        riskAnalysisForm,
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
    const { riskAnalysisForm } = await dataPreparationService.getRiskAnalysis({
      completed: false,
      tenantType: this.tenantType,
    });

    const outdatedVersion = (Number(riskAnalysisForm.version) - 1).toFixed(1);

    this.response = await apiClient.purposes.createPurpose(
      {
        eserviceId: this.eserviceId,
        consumerId,
        title: `purpose title - QA - ${this.TEST_SEED} - ${getRandomInt()}`,
        description: "description of the purpose - QA",
        isFreeOfCharge: true,
        freeOfChargeReason: "free of charge - QA",
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
        riskAnalysisForm: {
          ...riskAnalysisForm,
          version: outdatedVersion,
        },
      },
      getAuthorizationHeader(this.token)
    );
  }
);
