import { readFileSync } from "fs";
import { File } from "buffer";
import { apiClient } from "../api";
import {
  getAuthorizationHeader,
  getRandomInt,
  makePolling,
  assertValidResponse,
} from "../utils/commons";
import { EServiceSeed, EServiceDescriptorSeed } from "./../api/models";

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
      agreementApprovalPolicy: "MANUAL",
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
      (res) => res.data.state === "PENDING"
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
};
