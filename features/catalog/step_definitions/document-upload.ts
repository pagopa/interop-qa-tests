import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { EServiceTechnology } from "../../../api/models";
import {
  FileType,
  assertContextSchema,
  uploadInterfaceDocument,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { Party, Role } from "./common-steps";

Given(
  "un {string} di {string} ha già creato un e-service con un descrittore in stato DRAFT e tecnologia {string}",
  async function (role: Role, party: Party, technology: EServiceTechnology) {
    assertContextSchema(this);

    const token = this.tokens[party]![role]!;

    const eserviceId = await dataPreparationService.createEService(token, {
      technology,
    });

    const descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      eserviceId
    );

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);

When(
  "l'utente carica un documento di interfaccia di tipo {string}",
  async function (fileType: FileType) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    this.response = await uploadInterfaceDocument(
      `interface.${fileType}`,
      this.eserviceId,
      this.descriptorId,
      this.token
    );
  }
);

When(
  "l'utente carica un documento di interfaccia di tipo {string} che contiene il termine localhost",
  async function (fileType: FileType) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    this.response = await uploadInterfaceDocument(
      `localhost-interface.${fileType}`,
      this.eserviceId,
      this.descriptorId,
      this.token
    );
  }
);
