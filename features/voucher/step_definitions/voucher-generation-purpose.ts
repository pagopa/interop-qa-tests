import { randomUUID } from "crypto";
import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getToken,
  TenantType,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già richiesto la cancellazione della richiesta di aggiornamento della stima di carico",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.deletePurposeVersion(
      token,
      this.purposeId,
      this.waitingForApprovalVersionId
    );
  }
);

Given(
  "{string} ha già approvato la richiesta di aggiornamento della stima di carico",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activatePurposeVersion(
      token,
      this.purposeId,
      this.waitingForApprovalVersionId
    );

    this.currentVersionId = this.waitingForApprovalVersionId;
  }
);

Given(
  "{string} ha già rifiutato la richiesta di aggiornamento della stima di carico",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      waitingForApprovalVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.rejectPurposeVersion(
      token,
      this.purposeId,
      this.waitingForApprovalVersionId
    );
  }
);

Given(
  "{string} ha già sospeso la finalità che risulta sospesa dal fruitore",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.suspendPurpose(
      token,
      this.purposeId,
      this.currentVersionId,
      "CONSUMER"
    );
  }
);

Given(
  "{string} ha già sospeso la finalità che risulta sospesa dall'erogatore",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.suspendPurpose(
      token,
      this.purposeId,
      this.currentVersionId,
      "PROVIDER"
    );
  }
);

Given(
  "{string} ha già riattivato la finalità sospesa dal fruitore",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activatePurposeVersion(
      token,
      this.purposeId,
      this.currentVersionId,
      "CONSUMER"
    );
  }
);

Given(
  "{string} ha già riattivato la finalità sospesa dall'erogatore",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activatePurposeVersion(
      token,
      this.purposeId,
      this.currentVersionId,
      "PRODUCER"
    );
  }
);

Given(
  "l'utente possiede un identificativo di una purpose che non esiste",
  function () {
    this.purposeId = randomUUID();
  }
);
