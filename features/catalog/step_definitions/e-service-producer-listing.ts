import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
} from "../../../utils/commons";
import { Party } from "../../common-steps";

When(
  "l'utente richiede una operazione di listing sui propri e-services erogati",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.producers.getProducerEServices(
      { q: this.TEST_SEED, offset: 0, limit: 50 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing sui propri e-services erogati limitata ai primi {int} e-services",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.producers.getProducerEServices(
      { q: this.TEST_SEED, offset: 0, limit },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing sui propri e-services con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.producers.getProducerEServices(
      { q: this.TEST_SEED, offset, limit: 12 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing sui propri e-services fruiti da {string}",
  async function (consumer: Party) {
    assertContextSchema(this, {
      token: z.string(),
    });
    const consumerId = getOrganizationId(consumer);
    this.response = await apiClient.producers.getProducerEServices(
      { q: this.TEST_SEED, consumersIds: [consumerId], offset: 0, limit: 12 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing sui propri e-services filtrando per la keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.producers.getProducerEServices(
      { q: `${this.TEST_SEED}-${keyword}`, offset: 0, limit: 12 },
      getAuthorizationHeader(this.token)
    );
  }
);
