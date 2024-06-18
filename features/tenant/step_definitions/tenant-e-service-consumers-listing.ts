import { When, Then } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing dei fruitori",
  async function () {
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e la lista di fruitori contenente {string}",
  async function (_tenantType: TenantType) {
    return "pending";
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori con limit {int}",
  async function (_limit: number) {
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e la lista di {int} aderent(i)(e)",
  async function (_num: number) {
    return "pending";
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori con offset {int}",
  async function (offset: number) {
    this.offset = offset;
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e il giusto numero di risultati in base all'offset richiesto",
  async function () {
    return "pending";
  }
);

When(
  "l'utente richiede una operazione di listing dei fruitori filtrando per nome aderente {string}",
  async function (_nomeAderente: string) {
    return "pending";
  }
);
