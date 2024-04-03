import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import { EServiceTechnology } from "../../../api/models";
import {
  FileType,
  assertContextSchema,
  getToken,
  uploadInterfaceDocument,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { TenantType } from "../../common-steps";

Given(
  "{string} ha già creato un e-service con un descrittore in stato DRAFT e tecnologia {string}",
  async function (tenantType: TenantType, technology: EServiceTechnology) {
    assertContextSchema(this);

    const token = await getToken(tenantType);

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
