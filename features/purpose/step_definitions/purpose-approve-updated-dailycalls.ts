import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente inserisce una data stimata di approvazione di quell'aggiornamento della stima di carico",
  async function () {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string(),
      token: z.string(),
    });
    this.response =
      await apiClient.purposes.updateWaitingForApprovalPurposeVersion(
        this.purposeId,
        this.waitingForApprovalVersionId,
        {
          expectedApprovalDate: new Date(
            new Date().setDate(new Date().getDate() + 1)
          ).toISOString(),
        },
        getAuthorizationHeader(this.token)
      );
  }
);
