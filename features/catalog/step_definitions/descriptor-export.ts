import assert from "assert";
import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import AdmZip from "adm-zip";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  downloadFile,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente effettua una richiesta di export del descrittore",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    this.response = await apiClient.export.exportEServiceDescriptor(
      this.eserviceId,
      this.descriptorId,
      getAuthorizationHeader(this.token)
    );
  }
);

Then("il pacchetto risulta correttamente formattato", async function () {
  assertContextSchema(this, {
    response: z.object({
      data: z.object({
        url: z.string(),
      }),
    }),
  });
  const zipBuffer = await downloadFile(this.response.data.url);

  const zip = new AdmZip(zipBuffer);

  // Mi salvo i seguenti nel contesto per controlli futuri
  this.zipEntries = zip.getEntries();

  const configEntry: AdmZip.IZipEntry | undefined = this.zipEntries.find(
    (entry: AdmZip.IZipEntry) => entry.entryName.endsWith("configuration.json")
  );

  assert.ok(configEntry, "configuration.json not found");

  const configString = configEntry.getData().toString("utf-8");

  this.configJson = JSON.parse(configString);

  assert.ok(
    this.zipEntries.some((entry: AdmZip.IZipEntry) =>
      entry.entryName.endsWith(this.configJson.descriptor.interface.path)
    ),
    "interface not found"
  );
});

Then(
  "il documento di configurazione contiene anche l’analisi del rischio compilata dall’erogatore",
  function () {
    assertContextSchema(this, {
      zipEntries: z.array(
        z.object({
          entryName: z.string(),
        })
      ),
      configJson: z.object({
        riskAnalysis: z.array(z.unknown()),
      }),
    });
    assert.ok(
      this.configJson.riskAnalysis.length > 0,
      "riskAnalysis not found"
    );
  }
);

Then(
  "il pacchetto contiene anche i documenti che sono mappati nel documento di configurazione",
  function () {
    assertContextSchema(this, {
      zipEntries: z.array(
        z.object({
          entryName: z.string(),
        })
      ),
      configJson: z.object({
        descriptor: z.object({
          docs: z.array(z.object({ path: z.string() })),
        }),
      }),
    });

    const expectedDocuments = this.configJson.descriptor.docs.map(
      (doc) => doc.path
    );

    expectedDocuments.forEach((doc) => {
      assert.ok(
        this.zipEntries.some((entry) => entry.entryName.endsWith(doc)),
        "Document not found"
      );
    });
  }
);
