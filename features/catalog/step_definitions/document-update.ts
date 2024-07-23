import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  TenantType,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { dataPreparationService } from "../../../services/data-preparation.service";

When("l'utente aggiorna il nome di quel documento", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
    documentId: z.string(),
  });

  this.response = await apiClient.eservices.updateEServiceDocumentById(
    this.eserviceId,
    this.descriptorId,
    this.documentId,
    { prettyName: "updatedPrettyName" },
    getAuthorizationHeader(this.token)
  );
});

Given(
  "{string} ha già caricato due documenti con nome {string} e {string} in quel descrittore",
  async function (
    tenantType: TenantType,
    prettyName1: string,
    prettyName2: string
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const token = await getToken(tenantType);
    await dataPreparationService.addDocumentToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId,
      prettyName1
    );

    this.documentId2 = await dataPreparationService.addDocumentToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId,
      prettyName2
    );
  }
);

When(
  "l'utente modifica il nome del secondo documento in {string}",
  async function (prettyName: string) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      documentId2: z.string(),
    });
    this.response = await apiClient.eservices.updateEServiceDocumentById(
      this.eserviceId,
      this.descriptorId,
      this.documentId2,
      { prettyName },
      getAuthorizationHeader(this.token)
    );
  }
);
