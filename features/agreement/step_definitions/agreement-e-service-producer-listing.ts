import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing degli e-services che hanno una richiesta di fruizione attiva",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.producers.getAgreementEServiceProducers(
      { q: encodeURIComponent(this.TEST_SEED), limit: 50, offset: 0 },
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

    this.response = await apiClient.producers.getAgreementEServiceProducers(
      { q: encodeURIComponent(this.TEST_SEED), limit, offset: 0 },
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

    this.response = await apiClient.producers.getAgreementEServiceProducers(
      { q: encodeURIComponent(this.TEST_SEED), limit: 10, offset },
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

    this.response = await apiClient.producers.getAgreementEServiceProducers(
      {
        q: encodeURIComponent(`${this.TEST_SEED}-${keyword}`),
        limit: 10,
        offset: 0,
      },
      getAuthorizationHeader(this.token)
    );
  }
);
