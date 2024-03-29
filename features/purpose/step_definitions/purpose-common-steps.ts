import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import { PurposeVersionState } from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getToken,
  getOrganizationId,
  getRiskAnalysis,
} from "../../../utils/commons";
import { Role, TenantType } from "../../common-steps";

Given(
  "{string} ha già creato {int} finalità in stato {string} per quell'eservice",
  async function (
    tenantType: TenantType,
    n: number,
    purposeState: PurposeVersionState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = getToken(this.tokens, tenantType, "admin");
    const consumerId = getOrganizationId(tenantType);
    const { riskAnalysisForm } = getRiskAnalysis({
      completed: true,
      tenantType,
    });

    this.purposesIds = [];
    for (let index = 0; index < n; index++) {
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
          purposeState,
        });
      this.purposesIds.push(purposeId);
    }
    this.purposeId = this.purposesIds[0];
  }
);

Given(
  "un {string} di {string} ha già pubblicato quella versione di e-service",
  async function (role: Role, tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);

    await dataPreparationService.publishDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

Given(
  "un {string} di {string} ha già creato una finalità in stato {string} per quell'eservice associando quell'analisi del rischio creata dall'erogatore",
  async function (
    role: Role,
    tenantType: TenantType,
    purposeState: PurposeVersionState
  ) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      riskAnalysisId: z.string(),
    });

    const token = getToken(this.tokens, tenantType, role);
    const consumerId = getOrganizationId(tenantType);

    const { purposeId } =
      await dataPreparationService.createPurposeWithGivenState({
        token,
        testSeed: this.TEST_SEED,
        payload: {
          eserviceId: this.eserviceId,
          consumerId,
          riskAnalysisId: this.riskAnalysisId,
        },
        purposeState,
        eserviceMode: "RECEIVE",
      });

    this.purposeId = purposeId;
  }
);
