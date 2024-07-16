import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  makePolling,
} from "../../../utils/commons";
import {
  ESERVICE_DAILY_CALLS,
  dataPreparationService,
} from "../../../services/data-preparation.service";
import { PurposeVersion, PurposeVersionState } from "../../../api/models";

When(
  "l'utente aggiorna la stima di carico per quella finalità",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
    });

    this.newDailyCalls = ESERVICE_DAILY_CALLS.perConsumer;

    this.response = await apiClient.purposes.createPurposeVersion(
      this.purposeId,
      {
        dailyCalls: this.newDailyCalls,
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

Then(
  "si ottiene status code 200 e la nuova versione della finalità è stata creata in stato {string} con la nuova stima di carico",
  async function (desiredState: PurposeVersionState) {
    assertContextSchema(this, {
      token: z.string(),
      newDailyCalls: z.number(),
      response: z.object({
        status: z.number(),
        data: z.object({
          purposeId: z.string(),
          versionId: z.string(),
        }),
      }),
    });

    let version: PurposeVersion | undefined;

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(
          this.purposeId,
          getAuthorizationHeader(this.token)
        ),
      (res) => {
        version = res.data.versions.find(
          (v) => v.id === this.response.data.versionId
        );
        return Boolean(version);
      }
    );

    assert.equal(this.response.status, 200);
    assert.equal(version?.dailyCalls, this.newDailyCalls);
    assert.equal(version?.state, desiredState);
  }
);
