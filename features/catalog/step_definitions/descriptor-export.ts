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
        filename: z.string(),
        url: z.string(),
      }),
    }),
  });
  const zipBuffer = await downloadFile(this.response.data.url);

  const zip = new AdmZip(zipBuffer);

  // Mi salvo i seguenti nel contesto per controlli futuri
  this.zipEntries = zip.getEntries();

  const configEntry: AdmZip.IZipEntry | undefined = this.zipEntries.find(
    (entry: AdmZip.IZipEntry) => entry.entryName === "configuration.json"
  );
  if (configEntry) {
    this.configJson = configEntry.getData().toString("utf-8");
  }

  assert.ok(
    this.zipEntries.some(
      (entry: AdmZip.IZipEntry) => entry.entryName === "configuration.json"
    )
  );
  const allowedExtensions = [".yaml", ".json", ".wsdl", ".xml"];
  assert.ok(
    this.zipEntries.some((entry: AdmZip.IZipEntry) =>
      allowedExtensions.some((ext) => entry.entryName.endsWith(ext))
    )
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
      configJson: z.string(),
    });
    const { riskAnalysis } = JSON.parse(this.configJson);
    assert.ok(riskAnalysis.length > 0);
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
      configJson: z.string(),
    });
    const { docs } = JSON.parse(this.configJson);
    const expectedDocuments = docs.map((doc: { path: string }) => doc.path);

    expectedDocuments.forEach((doc: string) => {
      assert.ok(this.zipEntries.some((entry) => entry.entryName === doc));
    });
  }
);
