import { Given, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getToken,
  TenantType,
} from "../../../utils/commons";
import { apiClient } from "../../../api";
import {
  EServiceDescriptorState,
  AgreementApprovalPolicy,
} from "../../../api/models";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già creato uno specifico e-service in stato {string} con approvazione {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this);

    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        { name: `e-service ${this.TEST_SEED}` },
        { agreementApprovalPolicy }
      );

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId,
      descriptorId,
      descriptorState,
    });

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);
Given(
  "{string} ha già creato un altro specifico e-service in stato {string} con approvazione {string}",
  async function (
    tenantType: TenantType,
    descriptorState: EServiceDescriptorState,
    agreementApprovalPolicy: AgreementApprovalPolicy
  ) {
    assertContextSchema(this);

    const token = await getToken(tenantType);

    const { eserviceId, descriptorId } =
      await dataPreparationService.createEServiceAndDraftDescriptor(
        token,
        { name: `e-service altro ${this.TEST_SEED}` },
        { agreementApprovalPolicy }
      );

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId,
      descriptorId,
      descriptorState,
    });

    this.eserviceId = eserviceId;
    this.descriptorId = descriptorId;
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getAgreementsProducerEServices(
      { q: this.TEST_SEED, limit: 50, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva limitata ai primi {int} e-services",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getAgreementsProducerEServices(
      { q: this.TEST_SEED, limit, offset: 0 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getAgreementsProducerEServices(
      { q: this.TEST_SEED, limit: 10, offset },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getAgreementsProducerEServices(
      {
        q: `${this.TEST_SEED}-${keyword}`,
        limit: 10,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
