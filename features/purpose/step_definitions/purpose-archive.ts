import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { PurposeVersionState } from "../../../api/models";

When(
  "l'utente archivia quella finalità in stato {string}",
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

    this.response = await apiClient.purposes.archivePurposeVersion(
      this.purposeId,
      versionId,
      getAuthorizationHeader(this.token)
    );
  }
);
