import { z } from "zod";
import { When } from "@cucumber/cucumber";
import { apiClient } from "../../../api";
import {
  getAuthorizationHeader,
  assertContextSchema,
} from "../../../utils/commons";
import { ESERVICE_DAILY_CALLS } from "../../../services/data-preparation.service";

When(
  "l'utente aggiorna quella finalità per quell'e-service in erogazione inversa",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });

    this.response = await apiClient.reverse.updateReversePurpose(
      this.purposeId,
      {
        title: "some new title",
        description: "some new description",
        isFreeOfCharge: true,
        freeOfChargeReason: "some new free of charge reason",
        dailyCalls: ESERVICE_DAILY_CALLS.perConsumer - 1,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
