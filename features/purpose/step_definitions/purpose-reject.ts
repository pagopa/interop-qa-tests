import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api/client";
import {
  assertContextSchema,
  getAuthorizationHeader,
  makePolling,
} from "../../../utils/commons";

When(
  "l'utente rifiuta la finalità aggiungendo una motivazione",
  async function () {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string().optional(),
      currentVersionId: z.string().optional(),
    });

    const versionId = this.waitingForApprovalVersionId || this.currentVersionId;

    if (!versionId) {
      throw new Error("No versionId found");
    }

    this.response = await apiClient.purposes.rejectPurposeVersion(
      this.purposeId,
      versionId,
      {
        rejectionReason: "Motivazione di rifiuto",
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When("l'utente rifiuta la finalità senza una motivazione", async function () {
  assertContextSchema(this, {
    purposeId: z.string(),
    waitingForApprovalVersionId: z.string().optional(),
    currentVersionId: z.string().optional(),
  });

  const versionId = this.waitingForApprovalVersionId || this.currentVersionId;

  if (!versionId) {
    throw new Error("No versionId found");
  }

  this.response = await apiClient.purposes.rejectPurposeVersion(
    this.purposeId,
    versionId,
    {
      rejectionReason: "",
    },
    getAuthorizationHeader(this.token)
  );
});

Then(
  "la versione precedente della finalità rimane nello stato in cui si trovava prima del rifiuto",
  async function () {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });

    await makePolling(
      () => apiClient.purposes.getPurpose(this.purposeId),
      (res) => {
        const { currentVersion, rejectedVersion } = res.data;
        return !!rejectedVersion && currentVersion?.state === "ACTIVE";
      }
    );
  }
);
