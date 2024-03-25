import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
  makePolling,
} from "../../../utils/commons";
import { ESERVICE_DAILY_CALLS } from "../../../services/data-preparation.service";

When(
  "l'utente aggiorna la stima di carico per quella finalità",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });

    this.response = await apiClient.purposes.createPurposeVersion(
      this.purposeId,
      {
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Given(
  "l'utente crea una versione nuova della finalità in stato WAITING_FOR_APPROVAL",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });

    const response = await apiClient.purposes.createPurposeVersion(
      this.purposeId,
      {
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer + 1,
      },
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(
          this.purposeId,
          getAuthorizationHeader(this.token)
        ),
      (res) =>
        res.data.waitingForApprovalVersion?.state === "WAITING_FOR_APPROVAL"
    );
  }
);
