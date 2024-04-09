import { readFileSync } from "fs";
import { File } from "buffer";
import { AxiosResponse } from "axios";
import { apiClient } from "../api";
import {
  getAuthorizationHeader,
  getRandomInt,
  makePolling,
  assertValidResponse,
} from "../utils/commons";
import {
  EServiceSeed,
  EServiceDescriptorSeed,
  EServiceDescriptorState,
  EServiceRiskAnalysisSeed,
  DescriptorAttributesSeed,
  AgreementApprovalPolicy,
  AttributeKind,
  Attribute,
  PurposeVersionState,
  EServiceMode,
  CreatedResource,
  PurposeSeed,
  PurposeEServiceSeed,
  PurposeVersionSeed,
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

export const dataPreparationService = {
  async createEService(
    token: string,
    partialEserviceSeed: Partial<EServiceSeed> = {}
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

    await makePolling(
      () =>
        apiClient.producers.getProducerEServiceDetails(
          eserviceId,
          getAuthorizationHeader(token)
        ),
      (res) => res.status !== 404
    );

    return eserviceId;
  },

  async createDraftDescriptor(
    token: string,
    eserviceId: string,
    partialEServiceDescriptorSeed: Partial<EServiceDescriptorSeed> = {}
  ) {
    const DEFAULT_ESERVICE_DESCRIPTOR_SEED: EServiceDescriptorSeed = {
      description: "Questo è un e-service di test",
      audience: ["api/v1"],
      voucherLifespan: 60,
      dailyCallsPerConsumer: ESERVICE_DAILY_CALLS.perConsumer,
      dailyCallsTotal: ESERVICE_DAILY_CALLS.total,
      agreementApprovalPolicy: "AUTOMATIC",
      attributes: {
        certified: [],
        declared: [],
        verified: [],
      },
    };

    const eserviceDescriptorSeed: EServiceDescriptorSeed = {
      ...DEFAULT_ESERVICE_DESCRIPTOR_SEED,
      ...partialEServiceDescriptorSeed,
    };

    const descriptorCreationResponse =
      await apiClient.eservices.createDescriptor(
        eserviceId,
        eserviceDescriptorSeed,
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

    const response = await apiClient.eservices.createEServiceDocument(
      eserviceId,
      descriptorId,
      {
        kind: "DOCUMENT",
        prettyName: "Documento_test_qa",
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
      (res) => res.data.docs.some((doc) => doc.id === documentId)
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
    const response = await apiClient.eservices.publishDescriptor(
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

  async createAgreementWithGivenState(
    token: string,
    agreementState: string,
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
    agreementState: string,
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

  async createDescriptorWithGivenState({
    token,
    eserviceId,
    descriptorState,
    withDocument = false,
    attributes = { certified: [], declared: [], verified: [] },
    agreementApprovalPolicy = "AUTOMATIC",
  }: {
    token: string;
    eserviceId: string;
    descriptorState: EServiceDescriptorState;
    withDocument?: boolean;
    attributes?: DescriptorAttributesSeed;
    agreementApprovalPolicy?: AgreementApprovalPolicy;
  }) {
    // 1. Create DRAFT descriptor
    const descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      eserviceId,
      { attributes, agreementApprovalPolicy }
    );

    // 1.1 add document to descriptor
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
      await dataPreparationService.createDraftDescriptor(token, eserviceId);

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
    await apiClient.tenants.addCertifiedAttribute(
      tenantId,
      {
        id: attributeId,
      },
      getAuthorizationHeader(token)
    );
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
    attributeId: string
  ) {
    const response = await apiClient.tenants.verifyVerifiedAttribute(
      tenantId,
      {
        id: attributeId,
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
            !attr.revokedBy.some((revoker) => revoker.id === verifierId)
        )
    );
  },

  async declareDeclaredAttribute(
    token: string,
    tenantId: string,
    attributeId: string
  ) {
    await apiClient.tenants.addDeclaredAttribute(
      {
        id: attributeId,
      },
      getAuthorizationHeader(token)
    );
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
    await apiClient.tenants.revokeCertifiedAttribute(
      tenantId,
      attributeId,
      getAuthorizationHeader(token)
    );
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
    let versionId: string | undefined;

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => {
        versionId = res.data.currentVersion?.id;
        return res.status !== 404;
      }
    );

    if (!versionId) {
      throw new Error(`Purpose version for id ${purposeId} not found`);
    }

    if (purposeState === "DRAFT") {
      return { purposeId, versionId };
    }

    // 2. Activate the purpose version
    const activatePurposeResponse =
      await apiClient.purposes.activatePurposeVersion(
        purposeId,
        versionId,
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
        (res) =>
          res.data.waitingForApprovalVersion?.state === "WAITING_FOR_APPROVAL"
      );
      return { purposeId, versionId };
    }

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) => res.data.currentVersion?.state === "ACTIVE"
    );

    // 4. If the state required is SUSPENDED call the endpoint to suspend the purpose version
    if (purposeState === "SUSPENDED") {
      const suspendPurposeResponse =
        await apiClient.purposes.suspendPurposeVersion(
          purposeId,
          versionId,
          getAuthorizationHeader(token)
        );
      assertValidResponse(suspendPurposeResponse);
      await makePolling(
        () =>
          apiClient.purposes.getPurpose(
            purposeId,
            getAuthorizationHeader(token)
          ),
        (res) => res.data.currentVersion?.state === "SUSPENDED"
      );
    }

    // 5. If the state required is ARCHIVED call the endpoint to archive the purpose version
    if (purposeState === "ARCHIVED") {
      const archivePurposeResponse =
        await apiClient.purposes.archivePurposeVersion(
          purposeId,
          versionId,
          getAuthorizationHeader(token)
        );
      assertValidResponse(archivePurposeResponse);
      await makePolling(
        () =>
          apiClient.purposes.getPurpose(
            purposeId,
            getAuthorizationHeader(token)
          ),
        (res) => res.data.currentVersion?.state === "ARCHIVED"
      );
    }
    return { purposeId, versionId };
  },

  async createNewPurposeVersion(
    token: string,
    purposeId: string,
    { dailyCalls }: PurposeVersionSeed
  ) {
    const response = await apiClient.purposes.createPurposeVersion(
      purposeId,
      { dailyCalls },
      getAuthorizationHeader(token)
    );

    assertValidResponse(response);

    const shouldWaitForApproval = dailyCalls > ESERVICE_DAILY_CALLS.perConsumer;

    await makePolling(
      () =>
        apiClient.purposes.getPurpose(purposeId, getAuthorizationHeader(token)),
      (res) =>
        shouldWaitForApproval
          ? res.data.waitingForApprovalVersion?.state === "WAITING_FOR_APPROVAL"
          : res.data.currentVersion?.dailyCalls === dailyCalls
    );
  },
};
