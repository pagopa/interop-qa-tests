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
import { PurposeVersionState } from "../../../api/models";

Given(
  "{string} rimuove quella nuova chiave dal client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      newKeyId: z.string(),
    });

    console.log(this.newKeyId);
    const token = await getToken(tenantType);

    await dataPreparationService.deleteClientKeyById(
      this.clientId,
      this.newKeyId,
      token
    );
  }
);

Given(
  "{string} rimuove quella nuova finalità dal client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      newPurposeId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.deletePurpose(this.newPurposeId, token);
  }
);

Given("{string} cancella quel client", async function (tenantType: TenantType) {
  assertContextSchema(this, {
    clientId: z.string(),
  });

  const token = await getToken(tenantType);

  await dataPreparationService.deleteClient(this.clientId, token);
});

Given(
  "un {string} di {string} ha aggiunto una nuova chiave pubblica al client",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      clientId: z.string(),
      keyId: z.string(),
    });

    console.log("keyId", this.keyId);

    const token = await getToken(tenantType, role);

    const { privateKey, publicKey } = createKeyPairPEM();

    this.newPrivateKey = privateKey;
    this.newPublicKey = publicKey;

    this.newKey = keyToBase64(publicKey);

    this.newKeyId = await dataPreparationService.addPublicKeyToClient(
      token,
      this.clientId,
      {
        use: "SIG",
        alg: "RS256",
        name: `newKey-${this.TEST_SEED}-${getRandomInt()}`,
        key: this.newKey,
      }
    );
    console.log("newKeyId", this.newKeyId);
  }
);

Given(
  "{string} ha già creato {int} nuov(a)(e) finalità in stato {string} per quell'eservice",
  async function (
    tenantType: TenantType,
    n: number,
    purposeState: PurposeVersionState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });

    const token = await getToken(tenantType);
    const consumerId = getOrganizationId(tenantType);
    const { riskAnalysisForm } = await dataPreparationService.getRiskAnalysis({
      completed: true,
      tenantType,
    });

    this.newPurposesIds = this.newPurposesIds || [];
    this.newCurrentVersionIds = this.newCurrentVersionIds || [];
    this.neWaitingForApprovalVersionIds =
      this.neWaitingForApprovalVersionIds || [];
    for (let index = 0; index < n; index++) {
      const { purposeId, currentVersionId, waitingForApprovalVersionId } =
        await dataPreparationService.createPurposeWithGivenState({
          token,
          testSeed: this.TEST_SEED,
          eserviceMode: "DELIVER",
          payload: {
            eserviceId: this.eserviceId,
            consumerId,
            riskAnalysisForm,
          },
          purposeState,
        });
      this.newPurposesIds.push(purposeId);
      this.newCurrentVersionIds.push(currentVersionId);
      this.neWaitingForApprovalVersionIds.push(waitingForApprovalVersionId);
    }
    this.newPurposeId = this.newPurposesIds[this.newPurposesIds.length - 1];
    this.newCurrentVersionId =
      this.newCurrentVersionIds[this.newCurrentVersionIds.length - 1];
    this.neWaitingForApprovalVersionId =
      this.neWaitingForApprovalVersionIds[
        this.neWaitingForApprovalVersionIds.length - 1
      ];
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
