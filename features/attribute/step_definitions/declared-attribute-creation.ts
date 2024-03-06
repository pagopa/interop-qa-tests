import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getRandomInt,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When("l'utente crea un attributo dichiarato", async function () {
  assertContextSchema(this, { token: z.string() });

  this.response = await apiClient.declaredAttributes.createDeclaredAttribute(
    {
      description: "description test",
      name: `new declared attribute ${getRandomInt()}`,
    },
    getAuthorizationHeader(this.token)
  );
});
