import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { PurposeVersionState } from "../../../api/models";

Given(
  "{string} ha già creato un'altra finalità per quell'eservice superando i limiti di carico di quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);
    const { riskAnalysisForm } = await dataPreparationService.getRiskAnalysis({
      completed: true,
      tenantType,
    });

    const { purposeId, waitingForApprovalVersionId } =
      await dataPreparationService.createPurposeWithGivenState({
        token,
        testSeed: this.TEST_SEED,
        eserviceMode: "DELIVER",
        payload: {
          eserviceId: this.eserviceId,
          consumerId,
          riskAnalysisForm,
          dailyCalls: 999999,
        },
        purposeState: "WAITING_FOR_APPROVAL",
      });
    this.otherPurposeId = purposeId;
    this.otherWaitingForApprovalVersionId = waitingForApprovalVersionId;
  }
);

Given(
  "{string} ha già approvato la nuova richiesta di aggiornamento della stima di carico",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      otherPurposeId: z.string(),
      otherWaitingForApprovalVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activatePurposeVersion(
      token,
      this.otherPurposeId,
      this.otherWaitingForApprovalVersionId
    );
  }
);

Given(
  "{string} ha già creato e pubblicato un e-service con una soglia di carico tale da gestire una sola chiamata",
  async function (tenantType: TenantType) {
    assertContextSchema(this);

    const token = await getToken(tenantType);
    const eserviceName = `e-service-${this.TEST_SEED}}`;

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        {
          name: eserviceName,
        },
        { dailyCallsPerConsumer: 1, dailyCallsTotal: 1 }
      );

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;

    await dataPreparationService.addInterfaceToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );

    await dataPreparationService.publishDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

When(
  "l'utente (ri)attiva la finalità in stato {string} per quell'e-service",
  async function (state: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      currentVersionId: z.string().optional(),
      waitingForApprovalVersionId: z.string().optional(),
      purposeId: z.string(),
    });
    const versionId =
      state === "WAITING_FOR_APPROVAL" || state === "REJECTED"
        ? this.waitingForApprovalVersionId
        : this.currentVersionId;
    this.response = await apiClient.purposes.activatePurposeVersion(
      this.purposeId,
      versionId!,
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente (ri)attiva la prima finalità in stato {string} per quell'e-service",
  async function (state: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      currentVersionIds: z.array(z.string().optional()).optional(),
      waitingForApprovalVersionIds: z.array(z.string().optional()).optional(),
      purposesIds: z.array(z.string()),
    });
    const purposeId = this.purposesIds?.[0];
    const waitingForApprovalVersionId = this.waitingForApprovalVersionIds?.[0];
    const currentVersionId = this.currentVersionIds?.[0];
    const versionId =
      state === "WAITING_FOR_APPROVAL" || state === "REJECTED"
        ? waitingForApprovalVersionId
        : currentVersionId;

    if (!versionId) {
      throw new Error("No versionId found");
    }

    this.response = await apiClient.purposes.activatePurposeVersion(
      purposeId,
      versionId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la finalità in stato {string}",
  async function (statusCode: number, desiredState: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      response: z.object({
        status: z.number(),
        data: z.object({
          purposeId: z.string(),
          versionId: z.string(),
        }),
      }),
    });
    await makePolling(
      () =>
        apiClient.purposes.getPurpose(
          this.purposeId,
          getAuthorizationHeader(this.token)
        ),
      (res) =>
        desiredState === "WAITING_FOR_APPROVAL"
          ? res.data.waitingForApprovalVersion?.state === desiredState
          : desiredState === "REJECTED"
          ? res.data.rejectedVersion?.state === desiredState
          : res.data.currentVersion?.state === desiredState
    );
    assert.equal(this.response.status, statusCode);
  }
);
