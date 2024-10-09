import { readFileSync } from "fs";
import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  EServiceDescriptorState,
  EServiceTechnology,
} from "../../../api/models";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { FileType, TenantType } from "../../../utils/commons";
import { apiClient } from "../../../api";

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

    const fileName = `interface.${fileType}`;
    const blobFile = new Blob([readFileSync(`./data/${fileName}`)]);
    const file = new File([blobFile], fileName);

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
  "l'utente carica un documento di interfaccia di tipo {string} che contiene il termine localhost",
  async function (fileType: FileType) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const fileName = `localhost-interface.${fileType}`;
    const blobFile = new Blob([readFileSync(`./data/${fileName}`)]);
    const file = new File([blobFile], fileName);

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

Given(
  "{string} ha già caricato un documento con nome {string} in quel descrittore",
  async function (tenantType: TenantType, prettyName: string) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });
    const token = await getToken(tenantType);
    await dataPreparationService.addDocumentToDescriptor(
      token,
      this.eserviceId,
      this.descriptorId,
      prettyName
    );
  }
);

When(
  "l'utente carica un documento con nome {string} in quel descrittore",
  async function (prettyName: string) {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const blobFile = new Blob([readFileSync("./data/dummy.pdf")]);
    const file = new File([blobFile], "documento-test-qa.pdf");

    this.response = await apiClient.eservices.createEServiceDocument(
      this.eserviceId,
      this.descriptorId,
      {
        kind: "DOCUMENT",
        prettyName,
        doc: file,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
