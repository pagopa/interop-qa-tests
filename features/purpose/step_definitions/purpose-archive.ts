import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { TenantType } from "../../common-steps";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";
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
      state === "WAITING_FOR_APPROVAL"
        ? this.waitingForApprovalVersionId
        : this.currentVersionId;
    this.response = await apiClient.purposes.archivePurposeVersion(
      this.purposeId,
      versionId!,
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "{string} ha già richiesto l'aggiornamento della stima di carico superando i limiti di quell'e-service",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
    });

    const token = getToken(this.tokens, tenant, "admin");

    const { waitingForApprovalVersionId } =
      await dataPreparationService.createNewPurposeVersion(
        token,
        this.purposeId,
        { dailyCalls: ESERVICE_DAILY_CALLS.perConsumer + 1 }
      );
    this.waitingForApprovalVersionId = waitingForApprovalVersionId;
  }
);
