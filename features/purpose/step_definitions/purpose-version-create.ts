import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";

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
    await dataPreparationService.createNewPurposeVersion(
      this.token,
      this.purposeId,
      { dailyCalls: ESERVICE_DAILY_CALLS.perConsumer + 1 }
    );
  }
);
