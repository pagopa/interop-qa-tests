import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRandomInt,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente crea un attributo certificato", async function () {
  assertContextSchema(this, { token: z.string() });

  this.response = await apiClient.certifiedAttributes.createCertifiedAttribute(
    {
      description: "description test",
      name: `new certified attribute ${getRandomInt()}`,
    },
    getAuthorizationHeader(this.token)
  );
});
