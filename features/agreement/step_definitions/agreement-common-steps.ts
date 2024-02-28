import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import { Role, TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import { assertContextSchema, getToken } from "../../../utils/commons";

Given(
  "un {string} di {string} ha già creato e pubblicato {int} e-service(s)",
  async function (role: Role, tenantType: TenantType, totalEservices: number) {
    assertContextSchema(this);
    const token = getToken(this.tokens, tenantType, role);

    const arr = new Array(totalEservices).fill(0);
    const createEServiceWithPublishedDescriptor = async (i: number) => {
      const eserviceId = await dataPreparationService.createEService(token, {
        name: `eservice-${i}-${this.TEST_SEED}`,
      });
      const { descriptorId } =
        await dataPreparationService.createDescriptorWithGivenState({
          token,
          eserviceId,
          descriptorState: "PUBLISHED",
        });

      return [eserviceId, descriptorId];
    };

    this.publishedEservicesIds = await Promise.all(
      arr.map((_, i) => createEServiceWithPublishedDescriptor(i))
    );
    this.eserviceId = this.publishedEservicesIds[0][0];
    this.descriptorId = this.publishedEservicesIds[0][1];
  }
);

Given(
  "{string} ha una richiesta di fruizione in stato {string} per quell'e-service",
  async function (consumer: TenantType, agreementState: string) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      token: z.string(),
    });
    const token = getToken(this.tokens, consumer, "admin");
    this.agreementId =
      await dataPreparationService.createAgreementWithGivenState(
        token,
        agreementState,
        this.eserviceId,
        this.descriptorId
      );
  }
);
