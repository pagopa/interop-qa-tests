import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
  uploadFile,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

Given(
  "l'utente ha già richiesto una presignedURL per il caricamento del pacchetto",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    const response = await apiClient.import.getImportEservicePresignedUrl(
      {
        fileName:
          "ce25dbb7-8866-4b55-829c-492976bf579e_dd80f4c3-6f38-41c0-85a6-0d6288cca62e.zip",
      },
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(response);

    this.url = response.data.url;
  }
);

Given(
  "è già stato caricato il pacchetto nella presignedURL",
  async function () {
    assertContextSchema(this, {
      url: z.string(),
    });

    await uploadFile(
      this.url,
      "./data/ce25dbb7-8866-4b55-829c-492976bf579e_dd80f4c3-6f38-41c0-85a6-0d6288cca62e.zip"
    );
  }
);

When(
  "l'utente effettua una richiesta di import del descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.import.importEService(
      {
        filename:
          "ce25dbb7-8866-4b55-829c-492976bf579e_dd80f4c3-6f38-41c0-85a6-0d6288cca62e.zip",
        url: this.url,
      },
      getAuthorizationHeader(this.token)
    );

    assertValidResponse(this.response);
  }
);
