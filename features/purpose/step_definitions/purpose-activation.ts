import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { PurposeVersionState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già creato e pubblicato un e-service con una soglia di carico tale da contenere una sola finalità",
  async function (tenantType: TenantType) {
    assertContextSchema(this);

    const token = await getToken(tenantType);
    const eserviceName = `e-service-${this.TEST_SEED}}`;
    this.eserviceId = await dataPreparationService.createEService(token, {
      name: eserviceName,
    });

    this.descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      this.eserviceId,
      {
        dailyCallsPerConsumer: 1,
        dailyCallsTotal: 1,
      }
    );

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
      state === "WAITING_FOR_APPROVAL"
        ? waitingForApprovalVersionId
        : currentVersionId;
    this.response = await apiClient.purposes.activatePurposeVersion(
      purposeId,
      versionId!,
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
          : res.data.currentVersion?.state === desiredState
    );
    assert.equal(this.response.status, statusCode);
  }
);
