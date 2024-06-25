import { Given } from "@cucumber/cucumber";
import { z } from "zod";
import { TenantType } from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  assertContextSchema,
  getOrganizationId,
  getRandomInt,
  getToken,
} from "../../../utils/commons";
import {
  EServiceDescriptorState,
  AgreementApprovalPolicy,
  AgreementState,
} from "../../../api/models";

Given(
  "{string} ha già creato un e-service in stato {string} con approvazione {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    const token = await getToken(tenantType);
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
  "{string} ha già creato e pubblicato {int} e-service(s)",
  async function (tenantType: TenantType, totalEservices: number) {
    assertContextSchema(this);
    const token = await getToken(tenantType);

    const arr = new Array(totalEservices).fill(0);
    const createEServiceWithPublishedDescriptor = async (i: number) => {
      const eserviceId = await dataPreparationService.createEService(token, {
        name: `eservice-${i}-${this.TEST_SEED}-${getRandomInt()}`,
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
    const token = await getToken(consumer);
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
  "{string} ha creato un attributo certificato e lo ha assegnato a {string}",
  async function (certifier: TenantType, tenantType: TenantType) {
    const token = await getToken(certifier);

    this.tenantId = getOrganizationId(tenantType);
    this.attributeId = await dataPreparationService.createAttribute(
      token,
      "CERTIFIED"
    );

    await dataPreparationService.assignCertifiedAttributeToTenant(
      token,
      this.tenantId,
      this.attributeId
    );
  }
);

Given(
  "{string} ha già dichiarato un attributo",
  async function (tenantType: TenantType) {
    const tenantId = getOrganizationId(tenantType);
    const token = await getToken(tenantType);

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

Given(
  "{string} ha una richiesta di fruizione in stato {string} per ognuno di quegli e-services",
  async function (consumer: TenantType, agreementState: string) {
    assertContextSchema(this, {
      publishedEservicesIds: z.array(z.array(z.string())),
      token: z.string(),
    });
    const token = await getToken(consumer);

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
  "{string} ha già creato una richiesta di fruizione in stato {string} con un documento allegato",
  async function (consumer: TenantType, agreementState: AgreementState) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
      token: z.string(),
    });
    const token = await getToken(consumer);
    const [agreementId, documentId] =
      await dataPreparationService.createAgreementWithGivenStateAndDocument(
        token,
        agreementState,
        this.eserviceId,
        this.descriptorId
      );
    this.agreementId = agreementId;
    this.documentId = documentId;
  }
);
