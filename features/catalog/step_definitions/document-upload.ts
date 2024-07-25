import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  EServiceDescriptorState,
  EServiceTechnology,
} from "../../../api/models";
import { assertContextSchema, getToken } from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { FileType, TenantType } from "../../../utils/commons";

Given(
  "{string} ha già creato un e-service con un descrittore in stato {string} e tecnologia {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    technology: EServiceTechnology
  ) {
    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        {
          technology,
        },
        {}
      );

    const { documentId } =
      await dataPreparationService.bringDescriptorToGivenState({
        token,
        eserviceId,
        descriptorId,
        descriptorState,
      });
    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
    this.documentId = documentId;
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

    this.response = await dataPreparationService.uploadInterfaceDocument(
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

    this.response = await dataPreparationService.uploadInterfaceDocument(
      `localhost-interface.${fileType}`,
      this.eserviceId,
      this.descriptorId,
      this.token
    );
  }
);
