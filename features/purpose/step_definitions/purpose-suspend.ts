import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When("l'utente sospende quella finalità", async function () {
  assertContextSchema(this, {
    token: z.string(),
    purposeId: z.string(),
    versionId: z.string(),
  });

  this.response = await apiClient.purposes.suspendPurposeVersion(
    this.purposeId,
    this.versionId,
    getAuthorizationHeader(this.token)
  );
});
