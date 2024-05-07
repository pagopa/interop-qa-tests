import assert from "assert";
import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import { PurposeVersionState } from "../../../api/models";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getToken,
  getOrganizationId,
  getRiskAnalysis,
  getRandomInt,
} from "../../../utils/commons";
import { TenantType } from "../../common-steps";

Given(
  "{string} ha già creato {int} finalità in stato {string} per quell'eservice",
  async function (
    tenantType: TenantType,
    n: number,
    purposeState: PurposeVersionState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);
    const { riskAnalysisForm } = getRiskAnalysis({
      completed: true,
      tenantType,
    });

    this.purposesIds = this.purposesIds || [];
    this.currentVersionIds = this.currentVersionIds || [];
    this.waitingForApprovalVersionIds = this.waitingForApprovalVersionIds || [];
    for (let index = 0; index < n; index++) {
      const { purposeId, currentVersionId, waitingForApprovalVersionId } =
        await dataPreparationService.createPurposeWithGivenState({
          token,
          testSeed: this.TEST_SEED,
          eserviceMode: "DELIVER",
          payload: {
            eserviceId: this.eserviceId,
            consumerId,
            riskAnalysisForm,
          },
          purposeState,
        });
      this.purposesIds.push(purposeId);
      this.currentVersionIds.push(currentVersionId);
      this.waitingForApprovalVersionIds.push(waitingForApprovalVersionId);
    }
    this.purposeId = this.purposesIds[this.purposesIds.length - 1];
    this.currentVersionId =
      this.currentVersionIds[this.currentVersionIds.length - 1];
    this.waitingForApprovalVersionId =
      this.waitingForApprovalVersionIds[
        this.waitingForApprovalVersionIds.length - 1
      ];
  }
);

Given(
  "{string} ha già pubblicato quella versione di e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.publishDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

Given(
  "{string} ha già creato una finalità in stato {string} per quell'eservice associando quell'analisi del rischio creata dall'erogatore",
  async function (tenantType: TenantType, purposeState: PurposeVersionState) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);

    const { purposeId } =
      await dataPreparationService.createPurposeWithGivenState({
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

    this.purposeId = purposeId;
  }
);

Given(
  "{string} ha già creato un'analisi del rischio per quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);

    this.riskAnalysisId =
      await dataPreparationService.addRiskAnalysisToEService(
        token,
        this.eserviceId,
        getRiskAnalysis({ completed: true, tenantType })
      );
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} finalità",
  async function (statusCode: number, count: number) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          results: z.array(z.unknown()),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.results.length, count);
  }
);

Given(
  "{string} ha già creato una finalità in stato {string} per quell'e-service contenente la keyword {string}",
  async function (
    tenantType: TenantType,
    purposeState: PurposeVersionState,
    keyword: string
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);

    const { riskAnalysisForm } = getRiskAnalysis({
      completed: true,
      tenantType,
    });

    const title = `purpose ${this.TEST_SEED} - ${getRandomInt()} - ${keyword}`;
    const { purposeId } =
      await dataPreparationService.createPurposeWithGivenState({
        token,
        testSeed: this.TEST_SEED,
        eserviceMode: "DELIVER",
        payload: {
          title,
          eserviceId: this.eserviceId,
          consumerId,
          riskAnalysisForm,
        },
        purposeState,
      });
    this.purposeId = purposeId;
  }
);

Given(
  "{string} ha già rifiutato l'aggiornamento della stima di carico per quella finalità",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string(),
    });

    const token = await getToken(tenant);

    await dataPreparationService.rejectPurposeVersion(
      token,
      this.purposeId,
      this.waitingForApprovalVersionId
    );
  }
);

Given(
  "{string} ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
    });

    const token = await getToken(tenant);

    const { waitingForApprovalVersionId } =
      await dataPreparationService.createNewPurposeVersion(
        token,
        this.purposeId,
        { dailyCalls: ESERVICE_DAILY_CALLS.perConsumer + 1 }
      );
    this.waitingForApprovalVersionId = waitingForApprovalVersionId;
  }
);

Given(
  "{string} ha già portato la finalità in stato {string}",
  async function (
    tenantType: TenantType,
    desiredPurposeState: PurposeVersionState
  ) {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });
    const token = await getToken(tenantType);
    switch (desiredPurposeState) {
      case "ARCHIVED":
        await dataPreparationService.archivePurpose(
          token,
          this.purposeId,
          this.currentVersionId
        );
        break;

      case "SUSPENDED":
        await dataPreparationService.suspendPurpose(
          token,
          this.purposeId,
          this.currentVersionId
        );
        break;
      default:
        throw Error("To be implemented");
    }
  }
);

Then(
  "si ottiene status code {int} e il template in versione {string}",
  async function (statusCode: number, expectedVersion: string) {
    assertContextSchema(this, {
      response: z.object({
        status: z.number(),
        data: z.object({
          version: z.string(),
        }),
      }),
    });
    assert.equal(this.response.status, statusCode);
    assert.equal(this.response.data.version, expectedVersion);
  }
);
