import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { PurposeVersionState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType } from "../../common-steps";

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
      state === "WAITING_FOR_APPROVAL"
        ? this.waitingForApprovalVersionId
        : this.currentVersionId;
    this.response = await apiClient.purposes.activatePurposeVersion(
      this.purposeId,
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

Given(
  "{string} ha già approvato quella finalità in stato {string}",
  async function (tenantType: TenantType, state: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      currentVersionId: z.string().optional(),
      waitingForApprovalVersionId: z.string().optional(),
      purposeId: z.string(),
    });
    const token = await getToken(tenantType);
    const purposeVersionId =
      state === "WAITING_FOR_APPROVAL"
        ? this.waitingForApprovalVersionId
        : this.currentVersionId;

    const { versionId } = await dataPreparationService.activatePurposeVersion(
      token,
      this.purposeId,
      purposeVersionId!
    );

    this.currentVersionId = versionId;
  }
);
