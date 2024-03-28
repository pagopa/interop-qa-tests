import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { TenantType } from "../../common-steps";
import { PurposeVersionState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

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
    const token = getToken(this.tokens, tenantType, "admin");
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
