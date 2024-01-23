import { readFileSync } from "fs";
import { File } from "buffer";
import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { EServiceTechnology } from "../../../api/models";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
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
  "l'utente carica un documento di interfaccia con estensione {string}",
  async function (estensioneFile: string) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const blobFile = new Blob([
      readFileSync(`./utils/interface${estensioneFile}`),
    ]);
    const file = new File([blobFile], `interface${estensioneFile}`);

    this.response = await apiClient.eservices.createEServiceDocument(
      this.eserviceId,
      this.descriptorId,
      {
        kind: "INTERFACE",
        prettyName: "Interfaccia",
        doc: file,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente carica un documento di interfaccia con estensione {string} che contiene il termine localhost",
  async function (estensioneFile: string) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const blobFile = new Blob([
      readFileSync(`./utils/localhost-interface${estensioneFile}`),
    ]);
    const file = new File([blobFile], `localhost-interface${estensioneFile}`);

    this.response = await apiClient.eservices.createEServiceDocument(
      this.eserviceId,
      this.descriptorId,
      {
        kind: "INTERFACE",
        prettyName: "Interfaccia",
        doc: file,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
