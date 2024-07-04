import assert from "assert";
import { existsSync, readFileSync, unlinkSync, writeFileSync } from "fs";
import path from "path";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import AdmZip from "adm-zip";
import {
  assertContextSchema,
  assertValidResponse,
  getAuthorizationHeader,
  getRandomInt,
  makePolling,
  uploadFile,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import { EServiceMode } from "../../../api/models";

function updateAndZipConfig({
  folderName,
  updateConfig,
  notAllowedFiles = false,
}: {
  folderName: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  updateConfig: (config: any) => void;
  notAllowedFiles?: boolean;
}) {
  const folderPath = `./data/${folderName}`;
  const configFilePath = path.join(folderPath, "configuration.json");

  if (notAllowedFiles) {
    writeFileSync(path.join(folderPath, "notAllowedFile.txt"), "");
  } else {
    unlinkSync(path.join(folderPath, "notAllowedFile.txt"));
  }

  try {
    const configData = readFileSync(configFilePath, "utf-8");
    const configJson = JSON.parse(configData);

    // necessari in quanto alcuni test li modificano mentre tutti gli altri ne hanno bisogno
    if (!configJson.name) {
      configJson.name = `e-service-IMPORTED-${getRandomInt()}`;
    }
    if (
      configJson.descriptor.docs.length > 0 &&
      configJson.descriptor.docs[0].path === "unknown"
    ) {
      configJson.descriptor.docs[0].path = "documents/documento-test-qa.pdf";
    }

    updateConfig(configJson);

    writeFileSync(configFilePath, JSON.stringify(configJson, null, 2), "utf-8");

    const zip = new AdmZip();
    zip.addLocalFolder(folderPath);
    const zipFilePath = path.join(folderPath, "..", `${folderName}.zip`);

    if (existsSync(zipFilePath)) {
      unlinkSync(zipFilePath);
    }
    zip.writeZip(zipFilePath);
  } catch (error) {
    console.error(
      "Errore durante l'aggiornamento del file JSON o la compressione della cartella:",
      error
    );
  }
}

Given(
  "l'utente ha già un pacchetto correttamente strutturato con un eservice in mode {string}",
  function (eserviceMode: EServiceMode) {
    assertContextSchema(this);

    this.folderName =
      eserviceMode === "DELIVER"
        ? "exportedWithDocument"
        : "exportedWithRiskAnalysis";

    updateAndZipConfig({
      folderName: this.folderName,
      updateConfig: (configJson) => {
        configJson.name = `e-service-IMPORTED-${getRandomInt()}`;
      },
    });
  }
);

Given(
  "l'utente ha già un pacchetto non correttamente strutturato con campi richiesti mancanti",
  function () {
    assertContextSchema(this);

    this.folderName = "exportedWithDocument";

    updateAndZipConfig({
      folderName: this.folderName,
      updateConfig: (configJson) => {
        // eslint-disable-next-line fp/no-delete
        delete configJson.name;
      },
    });
  }
);

Given(
  "l'utente ha già un pacchetto non correttamente strutturato con documenti mancanti nel percorso previsto",
  function () {
    assertContextSchema(this);

    this.folderName = "exportedWithDocument";

    updateAndZipConfig({
      folderName: this.folderName,
      updateConfig: (configJson) => {
        configJson.descriptor.docs[0].path = "unknown";
      },
    });
  }
);

Given(
  "l'utente ha già un pacchetto non correttamente strutturato con file non previsti",
  function () {
    assertContextSchema(this);

    this.folderName = "exportedWithDocument";

    updateAndZipConfig({
      folderName: this.folderName,
      updateConfig: (configJson) => {
        configJson.name = `e-service-IMPORTED-${getRandomInt()}`;
      },
      notAllowedFiles: true,
    });
  }
);

Given(
  "l'utente ha già richiesto una presignedURL per il caricamento del pacchetto",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      folderName: z.string(),
    });

    const response = await apiClient.import.getImportEservicePresignedUrl(
      {
        fileName: `${this.folderName}.zip`,
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
      folderName: z.string(),
    });

    await uploadFile(this.url, `./data/${this.folderName}.zip`);
  }
);

When(
  "l'utente effettua una richiesta di import del descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      folderName: z.string(),
    });

    this.response = await apiClient.import.importEService(
      {
        filename: `${this.folderName}.zip`,
        url: this.url,
      },
      getAuthorizationHeader(this.token)
    );

    this.eserviceId = this.response.data.id;
    this.descriptorId = this.response.data.descriptorId;
  }
);

When(
  "l'utente effettua una richiesta di import del descrittore con nome del file errato",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.import.importEService(
      {
        filename: `unknown.zip`,
        url: this.url,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "il descrittore viene correttamente creato in stato DRAFT",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          this.eserviceId,
          this.descriptorId,
          getAuthorizationHeader(this.token)
        ),
      (response) => response.status !== 404
    );

    const { data } = await apiClient.producers.getProducerEServiceDescriptor(
      this.eserviceId,
      this.descriptorId,
      getAuthorizationHeader(this.token)
    );

    assert.equal(data.state, "DRAFT");

    this.descriptor = data;
  }
);

Then("i documenti risultano correttamente caricati", async function () {
  assertContextSchema(this, {
    token: z.string(),
    eserviceId: z.string(),
    descriptorId: z.string(),
  });

  await makePolling(
    () =>
      apiClient.producers.getProducerEServiceDescriptor(
        this.eserviceId,
        this.descriptorId,
        getAuthorizationHeader(this.token)
      ),
    (response) => response.status !== 404 && response.data.docs.length > 0
  );

  const { data } = await apiClient.producers.getProducerEServiceDescriptor(
    this.eserviceId,
    this.descriptorId,
    getAuthorizationHeader(this.token)
  );

  assert.ok(data.docs.length > 0, "docs not found");

  this.descriptor = data;
});

Then("l'eservice contiene l'analisi del rischio", function () {
  assertContextSchema(this, {
    descriptor: z.object({
      eservice: z.object({
        riskAnalysis: z.array(z.unknown()),
      }),
    }),
  });

  assert.ok(
    this.descriptor.eservice.riskAnalysis.length > 0,
    "riskAnalysis not found"
  );
});
