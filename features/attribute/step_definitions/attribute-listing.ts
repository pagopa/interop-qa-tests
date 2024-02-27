import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  TOBE_REMOVED_customSerializer,
  assertContextSchema,
  getAuthorizationHeader,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

When(
  "l'utente richiede una operazione di listing degli attributi",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.attributes.getAttributes(
      {
        q: this.TEST_SEED,
        limit: 50,
        offset: 0,
        kinds: ["DECLARED", "CERTIFIED", "VERIFIED"],
      },
      {
        ...getAuthorizationHeader(this.token),
        paramsSerializer: TOBE_REMOVED_customSerializer,
      }
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli attributi limitata ai primi {int} attributi",
  async function (limit: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.attributes.getAttributes(
      {
        q: this.TEST_SEED,
        limit,
        offset: 0,
        kinds: ["DECLARED", "CERTIFIED", "VERIFIED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di listing degli attributi con offset {int}",
  async function (offset: number) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.attributes.getAttributes(
      {
        q: this.TEST_SEED,
        limit: 50,
        offset,
        kinds: ["DECLARED", "CERTIFIED", "VERIFIED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);
When(
  'l\'utente richiede una operatione di listing degli attributi filtrando per tipo "certificato" e "verificato"',
  async function () {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.attributes.getAttributes(
      {
        q: this.TEST_SEED,
        limit: 50,
        offset: 0,
        kinds: ["CERTIFIED", "VERIFIED"],
      },
      {
        ...getAuthorizationHeader(this.token),
        paramsSerializer: TOBE_REMOVED_customSerializer,
      }
    );
  }
);
When(
  "l'utente richiede una operazione di listing degli attributi filtrando per keyword {string} all'interno del nome",
  async function (keyword: string) {
    assertContextSchema(this, {
      token: z.string(),
    });
    this.response = await apiClient.attributes.getAttributes(
      {
        q: `${this.TEST_SEED}-${keyword}`,
        limit: 50,
        offset: 0,
        kinds: ["CERTIFIED", "DECLARED", "VERIFIED"],
      },
      getAuthorizationHeader(this.token)
    );
  }
);
