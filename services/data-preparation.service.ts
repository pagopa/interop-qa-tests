import { readFileSync } from "fs";
import { File } from "buffer";
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
} from "./../api/models";

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
      dailyCallsPerConsumer: 10,
      dailyCallsTotal: 100,
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
    const blobFile = new Blob([readFileSync("./utils/interface.yaml")]);
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
    const blobFile = new Blob([readFileSync("./utils/dummy.pdf")]);
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

  async submitAgreement(token: string, agreementId: string) {
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
      (res) => res.data.state === "ACTIVE" || res.data.state === "PENDING"
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

  async createDescriptorWithGivenState({
    token,
    eserviceId,
    descriptorState,
    withDocument = false,
  }: {
    token: string;
    eserviceId: string;
    descriptorState: EServiceDescriptorState;
    withDocument?: boolean;
  }) {
    // 1. Create DRAFT descriptor
    const descriptorId = await dataPreparationService.createDraftDescriptor(
      token,
      eserviceId
    );

    if (descriptorState === "DRAFT") {
      return { descriptorId };
    }

    // 2. Add interface to descriptor
    await dataPreparationService.addInterfaceToDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    // 2.1 add document to descriptor
    let documentId: string | undefined;
    if (withDocument) {
      documentId = await dataPreparationService.addDocumentToDescriptor(
        token,
        eserviceId,
        descriptorId
      );
    }

    // 3. Publish Descriptor
    await dataPreparationService.publishDescriptor(
      token,
      eserviceId,
      descriptorId
    );

    if (descriptorState === "PUBLISHED") {
      return { descriptorId, documentId };
    }

    // 4. Suspend Descriptor
    if (descriptorState === "SUSPENDED") {
      await dataPreparationService.suspendDescriptor(
        token,
        eserviceId,
        descriptorId
      );
      return { descriptorId, documentId };
    }

    if (descriptorState === "ARCHIVED" || descriptorState === "DEPRECATED") {
      if (descriptorState === "DEPRECATED") {
        // Optional. Create an agreement

        const agreementId = await dataPreparationService.createAgreement(
          token,
          eserviceId,
          descriptorId
        );

        await dataPreparationService.submitAgreement(token, agreementId);
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

      return { descriptorId, documentId };
    }
    return { descriptorId, documentId };
  },
};
