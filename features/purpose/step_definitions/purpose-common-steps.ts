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
import { TenantType } from "../../common-steps";

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

    const token = await getToken(tenantType);
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
