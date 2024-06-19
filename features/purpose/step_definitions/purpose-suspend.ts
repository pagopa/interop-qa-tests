import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { PurposeVersionState } from "../../../api/models";

When(
  "l'utente sospende quella finalità in stato {string}",
  async function (state: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
      currentVersionId: z.string().optional(),
      waitingForApprovalVersionId: z.string().optional(),
    });
    const versionId =
      state === "WAITING_FOR_APPROVAL" || state === "REJECTED"
        ? this.waitingForApprovalVersionId
        : this.currentVersionId;

    if (!versionId) {
      throw new Error("No versionId found");
    }

    this.response = await apiClient.purposes.suspendPurposeVersion(
      this.purposeId,
      versionId,
      getAuthorizationHeader(this.token)
    );
  }
);
