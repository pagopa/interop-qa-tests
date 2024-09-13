import { readFileSync } from "fs";
import { File } from "buffer";
import { AxiosResponse } from "axios";
import { apiClient } from "../api";
import {
  getAuthorizationHeader,
  getRandomInt,
  makePolling,
  assertValidResponse,
  getToken,
  TenantType,
  sleep,
} from "../utils/commons";
import {
  EServiceSeed,
  EServiceDescriptorState,
  EServiceRiskAnalysisSeed,
  AttributeKind,
  Attribute,
  PurposeVersionState,
  EServiceMode,
  CreatedResource,
  PurposeSeed,
  PurposeEServiceSeed,
  PurposeVersionSeed,
  ClientSeed,
  ClientKind,
  KeySeed,
  MailSeed,
  AgreementState,
  UpdateEServiceDescriptorSeed,
} from "./../api/models";

export const ESERVICE_DAILY_CALLS: Readonly<{
  total: number;
  perConsumer: number;
}> = {
  // Con questi valori ci aspettiamo che nei listing ci siano al più 20 finalità create da un singolo fruitore
  // altrimenti si supera la soglia di carico disponibile
  total: 1000,
  perConsumer: 50,
};

type RiskAnalysisTemplateType = "PA" | "Privato/GSP";

const RISK_ANALYSIS_DATA: Record<
  RiskAnalysisTemplateType,
  { completed: unknown; uncompleted: unknown }
> = {
  "Privato/GSP": {
    completed: {
      purpose: ["INSTITUTIONAL"],
      institutionalPurpose: ["test"],
      usesPersonalData: ["NO"],
      usesThirdPartyPersonalData: ["NO"],
    },
    uncompleted: {
      purpose: ["INSTITUTIONAL"],
      usesPersonalData: ["NO"],
      usesThirdPartyPersonalData: ["NO"],
    },
  },
  PA: {
    completed: {
      purpose: ["INSTITUTIONAL"],
      institutionalPurpose: ["test"],
      personalDataTypes: ["WITH_NON_IDENTIFYING_DATA"],
      legalBasis: ["CONSENT"],
      knowsDataQuantity: ["NO"],
      deliveryMethod: ["CLEARTEXT"],
      policyProvided: ["YES"],
      confirmPricipleIntegrityAndDiscretion: ["true"],
      doneDpia: ["NO"],
      dataDownload: ["NO"],
      purposePursuit: ["MERE_CORRECTNESS"],
      checkedExistenceMereCorrectnessInteropCatalogue: ["true"],
      usesThirdPartyData: ["NO"],
      declarationConfirmGDPR: ["true"],
    },
    uncompleted: {
      purpose: ["INSTITUTIONAL"],
      institutionalPurpose: ["test"],
      legalBasis: ["CONSENT"],
      knowsDataQuantity: ["NO"],
      deliveryMethod: ["CLEARTEXT"],
      policyProvided: ["YES"],
      confirmPricipleIntegrityAndDiscretion: ["true"],
      doneDpia: ["NO"],
      dataDownload: ["NO"],
      purposePursuit: ["MERE_CORRECTNESS"],
      checkedExistenceMereCorrectnessInteropCatalogue: ["true"],
      usesThirdPartyData: ["NO"],
      declarationConfirmGDPR: ["true"],
    },
  },
};

export const dataPreparationService = {
  async createEServiceAndDraftDescriptor(
    token: string,
    partialEserviceSeed: Partial<EServiceSeed> = {},
    partialDescriptorSeed: Partial<UpdateEServiceDescriptorSeed> = {}
  ) {
    const DEFAULT_ESERVICE_SEED: EServiceSeed = {
      name: `e-service ${getRandomInt()}`,
      description: "Descrizione e-service",
      technology: "REST",
      mode: "DELIVER",
    };

    const eserviceSeed: EServiceSeed = {
      ...DEFAULT_ESERVICE_SEED,
      ...partialEserviceSeed,
    };

    const eserviceCreationResponse = await apiClient.eservices.createEService(
      eserviceSeed,
      getAuthorizationHeader(token)
    );
    assertValidResponse(eserviceCreationResponse);
    const eserviceId = eserviceCreationResponse.data.id;
    const descriptorId = eserviceCreationResponse.data.descriptorId;

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.status !== 404
    );

    // if (Object.keys(partialDescriptorSeed).length === 0) {
    //   return { eserviceId, descriptorId };
    // }

    await dataPreparationService.updateDraftDescriptor({
      token,
      eserviceId,
      descriptorId,
      partialDescriptorSeed,
    });

    return { eserviceId, descriptorId };
  },

  async createNextDraftDescriptor(token: string, eserviceId: string) {
    const descriptorCreationResponse =
      await apiClient.eservices.createDescriptor(
        eserviceId,
        getAuthorizationHeader(token)
      );

    assertValidResponse(descriptorCreationResponse);
    const descriptorId = descriptorCreationResponse.data.id;

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.status !== 404
    );

    return descriptorId;
  },

  async addInterfaceToDescriptor(
    token: string,
    eserviceId: string,
    descriptorId: string
  ) {
    const blobFile = new Blob([readFileSync("./data/interface.yaml")]);
    const file = new File([blobFile], "interface.yaml");

    const response = await apiClient.eservices.createEServiceDocument(
      eserviceId,
      descriptorId,
      {
        kind: "INTERFACE",
        prettyName: "Interfaccia",
        doc: file,
      },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.interface !== undefined
    );
  },

  async addDocumentToDescriptor(
    token: string,
    eserviceId: string,
    descriptorId: string
  ) {
    const blobFile = new Blob([readFileSync("./data/dummy.pdf")]);
    const file = new File([blobFile], "documento-test-qa.pdf");

    const prettyName = `Documento_test_qa-${getRandomInt()}`;

    const response = await apiClient.eservices.createEServiceDocument(
      eserviceId,
      descriptorId,
      {
        kind: "DOCUMENT",
        prettyName,
        doc: file,
      },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);
    const documentId = response.data.id;

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.docs.some((doc) => doc.prettyName === prettyName)
    );
    return documentId;
  },

  async deleteDocumentFromDescriptor(
    eserviceId: string,
    descriptorId: string,
    documentId: string,
    token: string
  ) {
    const response = await apiClient.eservices.deleteEServiceDocumentById(
      eserviceId,
      descriptorId,
      documentId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.docs.every((doc) => doc.id !== documentId)
    );
  },

  async publishDescriptor(
    token: string,
    eserviceId: string,
    descriptorId: string
  ) {
    await dataPreparationService.updateDraftDescriptor({
      token,
      eserviceId,
      descriptorId,
      partialDescriptorSeed: { audience: ["pagopa.it"] },
    });

    const publicationResponse = await apiClient.eservices.publishDescriptor(
      eserviceId,
      descriptorId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(publicationResponse);

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "PUBLISHED"
    );
  },

  async suspendDescriptor(
    token: string,
    eserviceId: string,
    descriptorId: string
  ) {
    const response = await apiClient.eservices.suspendDescriptor(
      eserviceId,
      descriptorId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "SUSPENDED"
    );
  },

  async activateDescriptor(
    token: string,
    eserviceId: string,
    descriptorId: string
  ) {
    const response = await apiClient.eservices.activateDescriptor(
      eserviceId,
      descriptorId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "PUBLISHED" || res.data.state === "DEPRECATED"
    );
  },

  async createAgreement(
    token: string,
    eserviceId: string,
    descriptorId: string
  ) {
    const response = await apiClient.agreements.createAgreement(
      { eserviceId, descriptorId },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    const agreementId = response.data.id;

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.status !== 404
    );

    return agreementId;
  },

  async upgradeAgreement(token: string, agreementId: string): Promise<string> {
    const response = await apiClient.agreements.upgradeAgreement(
      agreementId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    const newAgreementId = response.data.id;

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          newAgreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.status === 200
    );

    return newAgreementId;
  },

  async createAgreementWithGivenState(
    token: string,
    agreementState: AgreementState,
    eserviceId: string,
    descriptorId: string,
    doc?: File
  ) {
    // agreement in state DRAFT
    const agreementId = await this.createAgreement(
      token,
      eserviceId,
      descriptorId
    );

    if (doc) {
      await dataPreparationService.addConsumerDocumentToAgreement(
        token,
        agreementId,
        doc
      );
    }

    if (agreementState === "DRAFT") {
      return agreementId;
    }

    await this.submitAgreement(
      token,
      agreementId,
      agreementState === "PENDING" ? agreementState : "ACTIVE"
    );

    // agreement in state ACTIVE o PENDING
    if (agreementState === "ACTIVE" || agreementState === "PENDING") {
      return agreementId;
    }

    // agreement in state SUSPENDED
    await this.suspendAgreement(token, agreementId, "CONSUMER");

    if (agreementState === "SUSPENDED") {
      return agreementId;
    }

    // agreement in state ARCHIVED
    if (agreementState === "ARCHIVED") {
      await this.archiveAgreement(token, agreementId);
      return agreementId;
    }
  },

  async addConsumerDocumentToAgreement(
    token: string,
    agreementId: string,
    doc: File
  ) {
    await apiClient.agreements.addAgreementConsumerDocument(
      agreementId,
      {
        name: "documento-test-qa.pdf",
        prettyName: "documento-test-qa",
        doc,
      },
      getAuthorizationHeader(token)
    );

    await makePolling(
      async () =>
        await apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.consumerDocuments.length > 0
    );
  },

  async createAgreementWithGivenStateAndDocument(
    token: string,
    agreementState: AgreementState,
    eserviceId: string,
    descriptorId: string
  ) {
    const blobFile = new Blob([readFileSync("./data/dummy.pdf")]);
    const doc = new File([blobFile], "documento-test-qa.pdf");
    const agreementId = await this.createAgreementWithGivenState(
      token,
      agreementState,
      eserviceId,
      descriptorId,
      doc
    );
    const agreement = await apiClient.agreements.getAgreementById(
      agreementId!,
      getAuthorizationHeader(token)
    );
    const documentId = agreement.data.consumerDocuments[0].id;
    return [agreementId, documentId];
  },

  async submitAgreement(
    token: string,
    agreementId: string,
    expectedState: "ACTIVE" | "PENDING" = "ACTIVE"
  ) {
    const response = await apiClient.agreements.submitAgreement(
      agreementId,
      {},
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === expectedState
    );
  },

  async suspendAgreement(
    token: string,
    agreementId: string,
    suspendedBy: "PRODUCER" | "CONSUMER"
  ) {
    const response = await apiClient.agreements.suspendAgreement(
      agreementId,
      getAuthorizationHeader(token)
    );

    const suspendedByProperty =
      suspendedBy === "PRODUCER"
        ? "suspendedByProducer"
        : "suspendedByConsumer";

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) =>
        Boolean(res.data.state === "SUSPENDED" && res.data[suspendedByProperty])
    );
  },

  async archiveAgreement(token: string, agreementId: string) {
    const response = await apiClient.agreements.archiveAgreement(
      agreementId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "ARCHIVED"
    );
  },

  async activateAgreement(token: string, agreementId: string) {
    const response = await apiClient.agreements.activateAgreement(
      agreementId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "ACTIVE"
    );
  },

  async rejectAgreement(token: string, agreementId: string) {
    const response = await apiClient.agreements.rejectAgreement(
      agreementId,
      { reason: "Agreement rejected during QA" },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.agreements.getAgreementById(
          agreementId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === "REJECTED"
    );
  },

  async updateDraftDescriptor({
    token,
    eserviceId,
    descriptorId,
    partialDescriptorSeed = {},
  }: {
    token: string;
    eserviceId: string;
    descriptorId: string;
    partialDescriptorSeed: Partial<UpdateEServiceDescriptorSeed>;
  }) {
    const descriptor = await apiClient.producers.getProducerEServiceDescriptor(
      eserviceId,
      descriptorId,
      getAuthorizationHeader(token)
    );

    const currentDescriptorSeed: UpdateEServiceDescriptorSeed = {
      agreementApprovalPolicy: descriptor.data.agreementApprovalPolicy,
      attributes: {
        certified: descriptor.data.attributes.certified.map((attrSet) =>
          attrSet.map((attr) => ({
            id: attr.id,
            explicitAttributeVerification: attr.explicitAttributeVerification,
          }))
        ),
        declared: descriptor.data.attributes.declared.map((attrSet) =>
          attrSet.map((attr) => ({
            id: attr.id,
            explicitAttributeVerification: attr.explicitAttributeVerification,
          }))
        ),
        verified: descriptor.data.attributes.verified.map((attrSet) =>
          attrSet.map((attr) => ({
            id: attr.id,
            explicitAttributeVerification: attr.explicitAttributeVerification,
          }))
        ),
      },
      dailyCallsPerConsumer: descriptor.data.dailyCallsPerConsumer,
      dailyCallsTotal: descriptor.data.dailyCallsTotal,
      audience: descriptor.data.audience,
      voucherLifespan: descriptor.data.voucherLifespan,
    };

    const descriptorSeed: UpdateEServiceDescriptorSeed = {
      ...currentDescriptorSeed,
      dailyCallsPerConsumer: ESERVICE_DAILY_CALLS.perConsumer,
      dailyCallsTotal: ESERVICE_DAILY_CALLS.total,
      ...partialDescriptorSeed,
      audience: ["pagopa.it"],
    };

    const response = await apiClient.eservices.updateDraftDescriptor(
      eserviceId,
      descriptorId,
      descriptorSeed,
      getAuthorizationHeader(token)
    );
    assertValidResponse(response);

    await sleep(2000);
    // checking the result through polling would be complicated because we should retrieve which fields are being updated
  },

  async bringDescriptorToGivenState({
    token,
    eserviceId,
    descriptorId,
    descriptorState,
    withDocument = false,
  }: {
    token: string;
    eserviceId: string;
    descriptorId: string;
    descriptorState: EServiceDescriptorState;
    withDocument?: boolean;
  }) {
    // 1 add document to descriptor
    let documentId: string | undefined;
    if (withDocument) {
      documentId = await dataPreparationService.addDocumentToDescriptor(
        token,
        eserviceId,
        descriptorId
      );
    }

    const result = { descriptorId, documentId };

    if (descriptorState === "DRAFT") {
      return result;
    }

    // 2. Add interface to descriptor
    await dataPreparationService.addInterfaceToDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    // 3. Publish Descriptor
    await dataPreparationService.publishDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    if (descriptorState === "PUBLISHED") {
      return result;
    }

    // 4. Suspend Descriptor
    if (descriptorState === "SUSPENDED") {
      await dataPreparationService.suspendDescriptor(
        token,
        eserviceId,
        descriptorId
      );
      return result;
    }

    if (descriptorState === "DEPRECATED") {
      // Optional. Create an agreement

      const agreementId = await dataPreparationService.createAgreement(
        token,
        eserviceId,
        descriptorId
      );

      await dataPreparationService.submitAgreement(
        token,
        agreementId,
        "ACTIVE"
      );
    }

    // Create another DRAFT descriptor
    const secondDescriptorId =
      await dataPreparationService.createNextDraftDescriptor(token, eserviceId);

    // Add interface to secondDescriptor
    await dataPreparationService.addInterfaceToDescriptor(
      token,
      eserviceId,
      secondDescriptorId
    );

    // Publish secondDescriptor
    await dataPreparationService.publishDescriptor(
      token,
      eserviceId,
      secondDescriptorId
    );

    // Check until the first descriptor is in desired state
    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDescriptor(
          eserviceId,
          descriptorId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.state === descriptorState
    );

    return result;
  },

  async addRiskAnalysisToEService(
    token: string,
    eserviceId: string,
    data: EServiceRiskAnalysisSeed
  ) {
    const response = await apiClient.eservices.addRiskAnalysisToEService(
      eserviceId,
      data,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    let riskAnalysisId: string | undefined;
    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDetails(
          eserviceId,
          getAuthorizationHeader(token)
        ),
      (res) => {
        riskAnalysisId = res.data.riskAnalysis?.[0]?.id;
        return Boolean(riskAnalysisId);
      }
    );
    if (!riskAnalysisId) {
      throw new Error("Risk analysis not found");
    }
    return riskAnalysisId;
  },

  async createAttribute(
    token: string,
    attributeKind: AttributeKind,
    name?: string
  ) {
    let response: AxiosResponse<Attribute, unknown>;
    const actualName = name ?? `new_attribute_${getRandomInt()}`;
    switch (attributeKind) {
      case "CERTIFIED":
        response = await apiClient.certifiedAttributes.createCertifiedAttribute(
          {
            description: "description_test",
            name: actualName,
          },
          getAuthorizationHeader(token)
        );
        break;
      case "VERIFIED":
        response = await apiClient.verifiedAttributes.createVerifiedAttribute(
          {
            description: "description_test",
            name: actualName,
          },
          getAuthorizationHeader(token)
        );
        break;
      case "DECLARED":
        response = await apiClient.declaredAttributes.createDeclaredAttribute(
          {
            description: "description_test",
            name: actualName,
          },
          getAuthorizationHeader(token)
        );
        break;
      default:
        throw new Error(`Invalid attributeKind ${attributeKind}`);
    }
    assertValidResponse(response);
    await makePolling(
      () =>
        // we use getAttributes for polling and not getAttributeById because the former reads from event-sourcing, and the latter from readmodel
        apiClient.attributes.getAttributes(
          {
            q: actualName,
            limit: 1,
            offset: 0,
            kinds: [attributeKind],
          },
          getAuthorizationHeader(token)
        ),
      (res) => res.data.results.length > 0
    );
    return response.data.id;
  },

  async assignCertifiedAttributeToTenant(
    token: string,
    tenantId: string,
    attributeId: string
  ) {
    const response = await apiClient.tenants.addCertifiedAttribute(
      tenantId,
      {
        id: attributeId,
      },
      getAuthorizationHeader(token)
    );
    assertValidResponse(response);
    await makePolling(
      () =>
        apiClient.tenants.getCertifiedAttributes(
          tenantId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.attributes.some((attr) => attr.id === attributeId)
    );
  },

  async assignVerifiedAttributeToTenant(
    token: string,
    tenantId: string,
    verifierId: string,
    attributeId: string,
    expirationDate?: string
  ) {
    const response = await apiClient.tenants.verifyVerifiedAttribute(
      tenantId,
      {
        id: attributeId,
        expirationDate,
      },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.tenants.getVerifiedAttributes(
          tenantId,
          getAuthorizationHeader(token)
        ),
      (res) =>
        res.data.attributes.some(
          (attr) =>
            attr.id === attributeId &&
            attr.verifiedBy.some((verifier) => verifier.id === verifierId)
        )
    );
  },

  async declareDeclaredAttribute(
    token: string,
    tenantId: string,
    attributeId: string
  ) {
    const response = await apiClient.tenants.addDeclaredAttribute(
      {
        id: attributeId,
      },
      getAuthorizationHeader(token)
    );
    assertValidResponse(response);
    await makePolling(
      () =>
        apiClient.tenants.getDeclaredAttributes(
          tenantId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.attributes.some((attr) => attr.id === attributeId)
    );
  },

  async revokeCertifiedAttributeToTenant(
    token: string,
    tenantId: string,
    attributeId: string
  ) {
    const response = await apiClient.tenants.revokeCertifiedAttribute(
      tenantId,
      attributeId,
      getAuthorizationHeader(token)
    );
    assertValidResponse(response);
    await makePolling(
      () =>
        apiClient.tenants.getCertifiedAttributes(
          tenantId,
          getAuthorizationHeader(token)
        ),
      (res) =>
        res.data.attributes.some(
          (attr) => attr.id === attributeId && attr.revocationTimestamp
        )
    );
  },

  // eslint-disable-next-line sonarjs/cognitive-complexity
  async createPurposeWithGivenState<TEServiceMode extends EServiceMode>({
    token,
    testSeed,
    eserviceMode,
    payload,
    purposeState,
  }: {
    token: string;
    testSeed: string;
    eserviceMode: TEServiceMode;
    payload: TEServiceMode extends "DELIVER"
      ? Partial<PurposeSeed> & { eserviceId: string; consumerId: string }
      : Partial<PurposeEServiceSeed> & {
          eserviceId: string;
          consumerId: string;
          riskAnalysisId: string;
        };
    purposeState: PurposeVersionState;
  }) {
    let response: AxiosResponse<CreatedResource, unknown>;
    const defaultValues = {
      title: `purpose title - QA - ${testSeed} - ${getRandomInt()}`,
      description: "description of the purpose - QA",
      isFreeOfCharge: true,
      freeOfChargeReason: "free of charge - QA",
      dailyCalls:
        purposeState === "WAITING_FOR_APPROVAL"
          ? ESERVICE_DAILY_CALLS.perConsumer + 1
          : 1,
    };

    const data = { ...defaultValues, ...payload };

    // 1. Check which mode the eservice is and call the correct endpoint
    if (eserviceMode === "RECEIVE") {
      response = await apiClient.reverse.createPurposeForReceiveEservice(
        data as PurposeEServiceSeed,
        getAuthorizationHeader(token)
      );
    } else {
      response = await apiClient.purposes.createPurpose(
        data as PurposeSeed,
        getAuthorizationHeader(token)
      );
    }
    assertValidResponse(response);

    const purposeId = response.data.id;
    let currentVersionId = "";
    let waitingForApprovalVersionId = "";

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => {
        if (res.data.currentVersion?.id) {
          currentVersionId = res.data.currentVersion.id;
        }
        return res.status !== 404;
      }
    );

    if (purposeState === "DRAFT") {
      return { purposeId, currentVersionId };
    }

    // 2. Activate the purpose version
    const activatePurposeResponse =
      await apiClient.purposes.activatePurposeVersion(
        purposeId,
        currentVersionId,
        getAuthorizationHeader(token)
      );
    assertValidResponse(activatePurposeResponse);

    // 3. If the state required is WAITING_FOR_APPROVAL, we need to wait until the purpose version is in that state and return the purposeId
    if (purposeState === "WAITING_FOR_APPROVAL") {
      await makePolling(
        () =>
          apiClient.purposes.getPurpose(
            purposeId,
            getAuthorizationHeader(token)
          ),
        (res) => {
          if (res.data.waitingForApprovalVersion?.id) {
            waitingForApprovalVersionId = res.data.waitingForApprovalVersion.id;
          }
          return (
            res.data.waitingForApprovalVersion?.state === "WAITING_FOR_APPROVAL"
          );
        }
      );
      return { purposeId, waitingForApprovalVersionId };
    }

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => {
        if (res.data.currentVersion?.state === "ACTIVE") {
          currentVersionId = res.data.currentVersion.id;
          return true;
        }
        return false;
      }
    );

    // 4. If the state required is SUSPENDED call the endpoint to suspend the purpose version
    if (purposeState === "SUSPENDED") {
      const suspendPurposeResponse =
        await apiClient.purposes.suspendPurposeVersion(
          purposeId,
          currentVersionId,
          getAuthorizationHeader(token)
        );
      assertValidResponse(suspendPurposeResponse);
      await makePolling(
        () =>
          apiClient.purposes.getPurpose(
            purposeId,
            getAuthorizationHeader(token)
          ),
        (res) => {
          if (res.data.currentVersion?.state === "SUSPENDED") {
            currentVersionId = res.data.currentVersion.id;
            return true;
          }
          return false;
        }
      );
    }

    // 5. If the state required is ARCHIVED call the endpoint to archive the purpose version
    if (purposeState === "ARCHIVED") {
      const archivePurposeResponse =
        await apiClient.purposes.archivePurposeVersion(
          purposeId,
          currentVersionId,
          getAuthorizationHeader(token)
        );
      assertValidResponse(archivePurposeResponse);
      await makePolling(
        () =>
          apiClient.purposes.getPurpose(
            purposeId,
            getAuthorizationHeader(token)
          ),
        (res) => {
          if (res.data.currentVersion?.state === "ARCHIVED") {
            currentVersionId = res.data.currentVersion.id;
            return true;
          }
          return false;
        }
      );
    }
    return { purposeId, currentVersionId };
  },

  async createNewPurposeVersion(
    token: string,
    purposeId: string,
    { dailyCalls }: PurposeVersionSeed
  ): Promise<{
    purposeId: string;
    currentVersionId: string | undefined;
    waitingForApprovalVersionId: string | undefined;
  }> {
    const response = await apiClient.purposes.createPurposeVersion(
      purposeId,
      { dailyCalls },
      getAuthorizationHeader(token)
    );

    let currentVersionId = "";
    let waitingForApprovalVersionId: string | undefined;

    assertValidResponse(response);

    const shouldWaitForApproval = dailyCalls > ESERVICE_DAILY_CALLS.perConsumer;

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => {
        currentVersionId = res.data.currentVersion!.id;
        if (shouldWaitForApproval) {
          waitingForApprovalVersionId = res.data.waitingForApprovalVersion?.id;
          return (
            res.data.waitingForApprovalVersion?.state === "WAITING_FOR_APPROVAL"
          );
        }
        return res.data.currentVersion?.dailyCalls === dailyCalls;
      }
    );

    return {
      purposeId,
      currentVersionId,
      waitingForApprovalVersionId,
    };
  },

  async deletePurposeVersion(
    token: string,
    purposeId: string,
    waitingForApprovalVersionId: string
  ): Promise<void> {
    const response = await apiClient.purposes.deletePurposeVersion(
      purposeId,
      waitingForApprovalVersionId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => !res.data.waitingForApprovalVersion
    );
  },

  async rejectPurposeVersion(
    token: string,
    purposeId: string,
    versionId: string
  ) {
    const response = await apiClient.purposes.rejectPurposeVersion(
      purposeId,
      versionId,
      {
        rejectionReason: "Testing QA purposes",
      },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) =>
        res.data.versions.find((v) => v.id === versionId)?.state === "REJECTED"
    );
  },

  async archivePurpose(token: string, purposeId: string, versionId: string) {
    const response = await apiClient.purposes.archivePurposeVersion(
      purposeId,
      versionId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => res.data.currentVersion?.state === "ARCHIVED"
    );
    return response.data;
  },

  async suspendPurpose(
    token: string,
    purposeId: string,
    versionId: string,
    checkSuspendedBy?: "CONSUMER" | "PROVIDER"
  ) {
    const response = await apiClient.purposes.suspendPurposeVersion(
      purposeId,
      versionId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => {
        const isSuspended = res.data.currentVersion?.state === "SUSPENDED";
        if (!checkSuspendedBy) {
          return isSuspended;
        }
        switch (checkSuspendedBy) {
          case "CONSUMER":
            return Boolean(res.data.suspendedByConsumer);
          case "PROVIDER":
            return Boolean(res.data.suspendedByProducer);
        }
      }
    );
    return response.data;
  },

  async retrieveCurrentRiskAnalysisConfiguration(token: string) {
    const response =
      await apiClient.purposes.retrieveLatestRiskAnalysisConfiguration(
        getAuthorizationHeader(token)
      );

    assertValidResponse(response);

    return response.data;
  },

  async getRiskAnalysis({
    tenantType,
    completed,
  }: {
    tenantType: TenantType;
    completed?: boolean;
  }) {
    const templateType =
      tenantType === "PA1" || tenantType === "PA2" ? "PA" : "Privato/GSP";
    const templateStatus = completed ?? true ? "completed" : "uncompleted";

    const answers = RISK_ANALYSIS_DATA[templateType][templateStatus];

    const token = await getToken(tenantType);
    const { version } =
      await dataPreparationService.retrieveCurrentRiskAnalysisConfiguration(
        token
      );

    return {
      name: "finalità test",
      riskAnalysisForm: {
        version,
        answers,
      },
    };
  },
  async uploadInterfaceDocument(
    fileName: string,
    eserviceId: string,
    descriptorId: string,
    token: string
  ): Promise<AxiosResponse<CreatedResource>> {
    const blobFile = new Blob([readFileSync(`./data/${fileName}`)]);
    const file = new File([blobFile], fileName);

    return apiClient.eservices.createEServiceDocument(
      eserviceId,
      descriptorId,
      {
        kind: "INTERFACE",
        prettyName: "Interfaccia",
        doc: file,
      },
      getAuthorizationHeader(token)
    );
  },
  async activatePurposeVersion(
    token: string,
    purposeId: string,
    versionId: string,
    checkNotSuspendedBy?: "CONSUMER" | "PRODUCER"
  ) {
    const authHeader = getAuthorizationHeader(token);

    const response = await apiClient.purposes.activatePurposeVersion(
      purposeId,
      versionId,
      authHeader
    );

    assertValidResponse(response);

    await makePolling(
      () => apiClient.purposes.getPurpose(purposeId, authHeader),
      (res) => {
        const isActive =
          res.data.versions.find((v) => v.id === versionId)?.state === "ACTIVE";
        if (!checkNotSuspendedBy) {
          return isActive;
        }
        switch (checkNotSuspendedBy) {
          case "CONSUMER":
            return !res.data.suspendedByConsumer;
          case "PRODUCER":
            return !res.data.suspendedByProducer;
        }
      }
    );

    return response.data;
  },
  async createClient(
    token: string,
    clientKind: ClientKind,
    partialClintSeed: Partial<ClientSeed> = {}
  ) {
    const DEFAULT_CLIENT_SEED: ClientSeed = {
      name: `client ${getRandomInt()}`,
      description: "Descrizione client",
      members: [],
    };

    const clientSeed: ClientSeed = {
      ...DEFAULT_CLIENT_SEED,
      ...partialClintSeed,
    };

    const response =
      clientKind === "CONSUMER"
        ? await apiClient.clientsConsumer.createConsumerClient(
            clientSeed,
            getAuthorizationHeader(token)
          )
        : await apiClient.clientsApi.createApiClient(
            clientSeed,
            getAuthorizationHeader(token)
          );

    assertValidResponse(response);
    const clientId = response.data.id;

    await makePolling(
      () =>
        apiClient.clients.getClient(clientId, getAuthorizationHeader(token)),
      (res) => res.status !== 404
    );

    return clientId;
  },
  async addMemberToClient(token: string, clientId: string, userId: string) {
    let response: AxiosResponse | undefined;

    await makePolling(
      () =>
        apiClient.clients.addUserToClient(
          clientId,
          userId,
          getAuthorizationHeader(token)
        ),
      (res) => {
        // This is necessary because otherwise we receive a 429 (Too Many Requests)
        response = res;
        return res.status !== 500;
      }
    );

    assertValidResponse(response!);

    await makePolling(
      () =>
        apiClient.clients.getClientUsers(
          clientId,
          getAuthorizationHeader(token)
        ),
      (res) => res.data.some((user) => user.userId === userId)
    );
  },
  async addPurposeToClient(token: string, clientId: string, purposeId: string) {
    const response = await apiClient.clients.addClientPurpose(
      clientId,
      {
        purposeId,
      },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.clients.getClient(clientId, getAuthorizationHeader(token)),
      (res) => res.data.purposes.some((purp) => purp.purposeId === purposeId)
    );
  },
  async addPublicKeyToClient(
    token: string,
    clientId: string,
    keySeed: KeySeed
  ) {
    let response: AxiosResponse | undefined;

    await makePolling(
      () =>
        apiClient.clients.createKeys(
          clientId,
          [keySeed],
          getAuthorizationHeader(token)
        ),
      (res) => {
        // This is necessary because otherwise we receive a 429 (Too Many Requests)
        response = res;
        return res.status !== 500;
      }
    );

    assertValidResponse(response!);

    let kid: string | undefined;

    await makePolling(
      () =>
        apiClient.clients.getClientKeys(
          { clientId },
          getAuthorizationHeader(token)
        ),
      (res) => {
        const key = res.data.keys.find((k) => k.name === keySeed.name);
        kid = key?.keyId;
        return Boolean(key);
      }
    );

    return kid as string;
  },

  async removeMemberFromClient(
    token: string,
    clientId: string,
    userId: string
  ) {
    const response = await apiClient.clients.removeUserFromClient(
      clientId,
      userId,
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.clients.getClientUsers(
          clientId,
          getAuthorizationHeader(token)
        ),
      (res) => !res.data.some((user) => user.userId === userId)
    );
  },
  async addEmailToTenant(
    token: string,
    tenantId: string,
    mailSeed: Omit<MailSeed, "kind">
  ) {
    const response = await apiClient.tenants.addTenantMail(
      tenantId,
      {
        kind: "CONTACT_EMAIL",
        ...mailSeed,
      },
      getAuthorizationHeader(token)
    );
    assertValidResponse(response);

    await makePolling(
      () =>
        apiClient.tenants.getTenant(tenantId, getAuthorizationHeader(token)),
      (res) => res.data.contactMail?.address === mailSeed.address
    );
  },
  async revokeTenantAttribute(
    token: string,
    attributeKind: AttributeKind,
    tenantId: string,
    attributeId: string
  ) {
    switch (attributeKind) {
      case "CERTIFIED":
        const certifiedResponse =
          await apiClient.tenants.revokeCertifiedAttribute(
            tenantId,
            attributeId,
            getAuthorizationHeader(token)
          );
        assertValidResponse(certifiedResponse);
        await makePolling(
          () =>
            apiClient.tenants.getCertifiedAttributes(
              tenantId,
              getAuthorizationHeader(token)
            ),
          (res) =>
            res.data.attributes.some(
              (attr) => attr.id === attributeId && attr.revocationTimestamp
            )
        );
        break;

      case "VERIFIED":
        const verifiedResponse =
          await apiClient.tenants.revokeVerifiedAttribute(
            tenantId,
            attributeId,
            getAuthorizationHeader(token)
          );
        assertValidResponse(verifiedResponse);
        await makePolling(
          () =>
            apiClient.tenants.getVerifiedAttributes(
              tenantId,
              getAuthorizationHeader(token)
            ),
          (res) =>
            res.data.attributes.some(
              (attr) =>
                attr.id === attributeId &&
                attr.revokedBy.map((r) => r.revocationDate !== undefined)
            )
        );
        break;
      case "DECLARED":
        const declaredResponse =
          await apiClient.tenants.revokeDeclaredAttribute(
            attributeId,
            getAuthorizationHeader(token)
          );
        assertValidResponse(declaredResponse);
        await makePolling(
          () =>
            apiClient.tenants.getDeclaredAttributes(
              tenantId,
              getAuthorizationHeader(token)
            ),
          (res) =>
            res.data.attributes.some(
              (attr) => attr.id === attributeId && attr.revocationTimestamp
            )
        );
        break;
      default:
        break;
    }
  },
};
