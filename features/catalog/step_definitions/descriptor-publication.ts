import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { Party, Role } from "./common-steps";

Given(
  "un {string} di {string} ha già caricato un'interfaccia per quel descrittore",
  async function (role: Role, party: Party) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = this.tokens[party]![role]!;

    await dataPreparationService.addInterfaceToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

When("l'utente pubblica quel descrittore", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });

  this.response = await apiClient.eservices.publishDescriptor(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );
});
