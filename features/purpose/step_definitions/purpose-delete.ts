import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When("l'utente richiede la cancellazione della finalità", async function () {
  assertContextSchema(this, { purposeId: z.string() });
  this.response = await apiClient.purposes.deletePurpose(
    this.purposeId,
    getAuthorizationHeader(this.token)
  );
});
