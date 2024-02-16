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

Then("quell'e-service è stato cancellato", async function () {
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

Then("quell'e-service non è stato cancellato", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
  });

  // We don't have an exact way to assert that the eService "doesn't get deleted".
  // We can only check if it still exists after a reasonable time.
  await sleep(3000);

  const res = await apiClient.producers.getProducerEServiceDetails(
    this.eserviceId,
    getAuthorizationHeader(this.token)
  );
  assert.notEqual(res.status, 404);
});
