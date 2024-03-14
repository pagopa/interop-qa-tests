import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import { Role, TenantType } from "../../common-steps";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getOrganizationId,
  getToken,
} from "../../../utils/commons";
import {
  EServiceDescriptorState,
  AgreementApprovalPolicy,
} from "../../../api/models";

Given(
  "un {string} di {string} ha già creato un e-service in stato {string} con approvazione {string}",
  async function (
    role: Role,
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this);
    const token = getToken(this.tokens, tenantType, role);
    this.eserviceId = await dataPreparationService.createEService(token);
    const response =
      await dataPreparationService.createDescriptorWithGivenState({
        token,
        eserviceId: this.eserviceId,
        descriptorState,
        agreementApprovalPolicy,
      });
    this.descriptorId = response.descriptorId;
  }
);

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

Given(
  "{string} ha una richiesta di fruizione in stato {string} per ognuno di quegli e-services",
  async function (consumer: TenantType, agreementState: string) {
    assertContextSchema(this, {
      publishedEservicesIds: z.array(z.array(z.string())),
      token: z.string(),
    });
    const token = getToken(this.tokens, consumer, "admin");

    this.agreementIds = await Promise.all(
      this.publishedEservicesIds.map(([eserviceId, descriptorId]) =>
        dataPreparationService.createAgreementWithGivenState(
          token,
          agreementState,
          eserviceId,
          descriptorId
        )
      )
    );
  }
);

Given(
  "{string} ha creato un attributo certificato e lo ha assegnato a {string}",
  async function (certifier: TenantType, tenantType: TenantType) {
    assertContextSchema(this);
    const token = getToken(this.tokens, certifier, "admin");

    const tenantId = getOrganizationId(tenantType);
    this.attributeId = await dataPreparationService.createAttribute(
      token,
      "CERTIFIED"
    );

    await dataPreparationService.assignCertifiedAttributeToTenant(
      token,
      tenantId,
      this.attributeId
    );
  }
);

Given(
  "{string} dichiara un attributo dichiarato",
  async function (tenantType: TenantType) {
    assertContextSchema(this);
    const tenantId = getOrganizationId(tenantType);
    const token = getToken(this.tokens, tenantType, "admin");

    const attributeId = await dataPreparationService.createAttribute(
      token,
      "DECLARED"
    );

    await dataPreparationService.declareDeclaredAttribute(
      token,
      tenantId,
      attributeId
    );

    this.requiredDeclaredAttributes = [[attributeId]];
  }
);
