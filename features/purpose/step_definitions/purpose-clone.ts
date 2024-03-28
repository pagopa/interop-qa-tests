import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api/client";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di clonazione della finalità",
  async function () {
    assertContextSchema(this, {
      purposeId: z.string(),
      eserviceId: z.string(),
    });
    this.response = await apiClient.purposes.clonePurpose(
      this.purposeId,
      {
        eserviceId: this.eserviceId,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
