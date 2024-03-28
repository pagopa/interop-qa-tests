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
      versionId: z.string(),
      token: z.string(),
    });
    this.response =
      await apiClient.purposes.updateWaitingForApprovalPurposeVersion(
        this.purposeId,
        this.versionId,
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
      versionId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, "admin");
    switch (desiredPurposeState) {
      case "ARCHIVED":
        await dataPreparationService.archivePurpose(
          token,
          this.purposeId,
          this.versionId
        );
        break;

      case "SUSPENDED":
        await dataPreparationService.suspendPurpose(
          token,
          this.purposeId,
          this.versionId
        );
        break;
      default:
        throw Error("To be implemented");
    }
  }
);
