import { randomUUID } from "crypto";
import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  createKeyPairPEM,
  getOrganizationId,
  getRandomInt,
  getToken,
  keyToBase64,
  Role,
  TenantType,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} rimuove quella nuova chiave dal client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      newKeyId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.deleteClientKeyById(
      token,
      this.clientId,
      this.newKeyId
    );
  }
);

Given(
  "{string} rimuove quella chiave dal client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      keyId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.deleteClientKeyById(
      token,
      this.clientId,
      this.keyId
    );
  }
);

Given(
  "{string} rimuove quella nuova finalità dal client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      newPurposeId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.deletePurposeFromClient(
      token,
      this.clientId,
      this.newPurposeId
    );
  }
);

Given(
  "{string} rimuove quella finalità dal client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      purposeId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.deletePurposeFromClient(
      token,
      this.clientId,
      this.purposeId
    );
  }
);

Given("{string} cancella quel client", async function (tenantType: TenantType) {
  assertContextSchema(this, {
    clientId: z.string(),
  });

  const token = await getToken(tenantType);

  await dataPreparationService.deleteClient(token, this.clientId);
});

Given(
  "un {string} di {string} ha aggiunto una nuova chiave pubblica al client",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
    });

    const token = await getToken(tenantType, role);

    const { publicKey } = createKeyPairPEM();

    this.newKeyId = await dataPreparationService.addPublicKeyToClient(
      token,
      this.clientId,
      {
        use: "SIG",
        alg: "RS256",
        name: `newKey-${this.TEST_SEED}-${getRandomInt()}`,
        key: keyToBase64(publicKey),
      }
    );
  }
);

Given(
  "{string} ha già creato una nuova chiave pubblica senza associarla al client",
  async function (_tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
    });

    const { publicKey, privateKey } = createKeyPairPEM();

    this.publicKey = publicKey;
    this.privateKey = privateKey;

    this.keyId = randomUUID();
  }
);

Given(
  "{string} ha già creato una nuova finalità attiva per quell'eservice",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);
    const { riskAnalysisForm } = await dataPreparationService.getRiskAnalysis({
      completed: true,
      tenantType,
    });

    const { purposeId } =
      await dataPreparationService.createPurposeWithGivenState({
        token,
        testSeed: this.TEST_SEED,
        eserviceMode: "DELIVER",
        payload: {
          eserviceId: this.eserviceId,
          consumerId,
          riskAnalysisForm,
        },
        purposeState: "ACTIVE",
      });

    this.newPurposeId = purposeId;
  }
);

Given(
  "{string} ha già associato quella nuova finalità a quel client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      newPurposeId: z.string(),
      clientId: z.string(),
    });

    const token = await getToken(tenantType);

    this.response = await dataPreparationService.addPurposeToClient(
      token,
      this.clientId,
      this.newPurposeId
    );
  }
);
