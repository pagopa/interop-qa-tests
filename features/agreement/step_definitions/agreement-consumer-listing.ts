import { When } from "@cucumber/cucumber";
import { z } from "zod";
import { apiClient } from "../../../api";
import {
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });

    this.response = await apiClient.consumers.getAgreementEServiceConsumers(
      { q: this.TEST_SEED, offset: 0, limit: 50 },
      getAuthorizationHeader(this.token)
    );

    console.log("risposta:", this.response);
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione limitata a {int}",
  async function (limit: number) {
    assertContextSchema(this, {
      TEST_SEED: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.consumers.getAgreementEServiceConsumers(
      { q: this.TEST_SEED, offset: 0, limit },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      TEST_SEED: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.consumers.getAgreementEServiceConsumers(
      { q: this.TEST_SEED, offset, limit: 50 },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli e-services per cui ha una richiesta di fruizione con keyword {string}",
  async function (keyword: string) {
    assertContextSchema(this, {
      TEST_SEED: z.string(),
      token: z.string(),
    });

    this.response = await apiClient.consumers.getAgreementEServiceConsumers(
      { q: `${this.TEST_SEED}-${keyword}`, offset: 0, limit: 50 },
      getAuthorizationHeader(this.token)
    );
  }
);
