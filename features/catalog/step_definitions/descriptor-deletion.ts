import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  makePolling,
  sleep,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente cancella il descrittore di quell'e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });
  this.response = await apiClient.eservices.deleteDraft(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );
});

Then("quell'eservice è stato cancellato", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
  });

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDetails(
        this.eserviceId,
        getAuthorizationHeader(this.token)
      ),
    (res) => res.status === 404
  );
});

Then("quell'eservice non è stato cancellato", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
  });
  await sleep(3000);

  const res = await apiClient.producers.getProducerEServiceDetails(
    this.eserviceId,
    getAuthorizationHeader(this.token)
  );
  assert.notEqual(res.status, 404);
});
