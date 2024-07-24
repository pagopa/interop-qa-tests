import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  getAuthorizationHeader,
  getRandomInt,
  assertContextSchema,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

When("l'utente crea un e-service con lo stesso nome", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceName: z.string(),
  });
  this.response = await apiClient.eservices.createEService(
    {
      name: this.eserviceName,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(this.token)
  );
});

Given(
  "l'utente ha già creato un e-service contenente anche il primo descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    const eserviceName = `e-service-${getRandomInt()}`;

    const eserviceId =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        this.token,
        { name: eserviceName }
      );

    this.eserviceName = eserviceName;
    this.eserviceId = eserviceId;
  }
);

When("l'utente crea un e-service", async function () {
  assertContextSchema(this, {
    token: z.string(),
  });
  const eserviceName = `e-service-${getRandomInt()}`;
  const response = await apiClient.eservices.createEService(
    {
      name: eserviceName,
      description: "Questo è un e-service di test",
      technology: "REST",
      mode: "DELIVER",
    },
    getAuthorizationHeader(this.token)
  );
  this.eserviceName = eserviceName;
  this.response = response;
});
