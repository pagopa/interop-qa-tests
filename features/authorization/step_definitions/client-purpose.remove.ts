import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { apiClient } from "../../../api";
import { PurposeVersion } from "./../../../api/models";

Given(
  "{string} ha già associato la finalità a quel client",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      clientId: z.string(),
    });

    const token = await getToken(tenantType);

    this.response = await dataPreparationService.addPurposeToClient(
      token,
      this.clientId,
      this.purposeId
    );
  }
);

Given(
  "{string} ha già archiviato quella finalità",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      purposeId: z.string(),
      currentVersionId: z.string(),
    });

    const token = await getToken(tenantType);

    this.response = await dataPreparationService.archivePurpose(
      token,
      this.purposeId,
      this.currentVersionId
    );
  }
);

When(
  "l'utente richiede la disassociazione della finalità dal client",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      purposeId: z.string(),
      clientId: z.string(),
    });

    this.response = await apiClient.clients.removeClientPurpose(
      this.clientId,
      this.purposeId,
      getAuthorizationHeader(this.token)
    );
  }
);
