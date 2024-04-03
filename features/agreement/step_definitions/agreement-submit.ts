import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  makePolling,
} from "../../../utils/commons";
import { TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { AgreementState } from "../../../api/models";

When("l'utente inoltra quella richiesta di fruizione", async function () {
  assertContextSchema(this, {
    token: z.string(),
    agreementId: z.string(),
  });
  this.response = await apiClient.agreements.submitAgreement(
    this.agreementId,
    {},
    getAuthorizationHeader(this.token)
  );
});

Given(
  "{string} ha sospeso quell'e-service",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const token = getToken(this.tokens, tenant);
    this.response = await dataPreparationService.suspendDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

Then(
  "la richiesta di fruizione assume lo stato {string}",
  async function (agreementState: AgreementState) {
    assertContextSchema(this, { agreementId: z.string(), token: z.string() });
    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          this.agreementId,
          getAuthorizationHeader(this.token)
        ),
      (res) => res.data.state === agreementState
    );
  }
);

Given(
  "{string} non possiede uno specifico attributo dichiarato",
  async function (tenant: TenantType) {
    assertContextSchema(this, { token: z.string() });
    const token = getToken(this.tokens, tenant);

    const attributeId = await dataPreparationService.createAttribute(
      token,
      "DECLARED"
    );

    this.requiredDeclaredAttributes = [[attributeId]];
  }
);
