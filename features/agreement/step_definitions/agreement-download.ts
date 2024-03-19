import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  makePolling,
} from "../../../utils/commons";

Given(
  "l'attestazione di quella richiesta di fruizione è già stata generata",
  async function () {
    assertContextSchema(this, {
      agreementId: z.string(),
      token: z.string(),
    });
    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.agreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.data.isContractPresent
    );
  }
);

When(
  "l'utente richiede una operazione di download dell'attestazione della richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      agreementId: z.string(),
      token: z.string(),
    });
    this.response = await apiClient.agreements.getAgreementContract(
      this.agreementId,
      getAuthorizationHeader(this.token)
    );
  }
);
