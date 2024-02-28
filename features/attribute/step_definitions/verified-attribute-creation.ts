import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRandomInt,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente crea un attributo verificato", async function () {
  assertContextSchema(this, { token: z.string() });

  this.response = await apiClient.verifiedAttributes.createVerifiedAttribute(
    {
      description: "description test",
      name: `new verified attribute ${getRandomInt()}`,
    },
    getAuthorizationHeader(this.token)
  );
});
