import { When, Then } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli erogatori",
  async function () {
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e la lista di erogatori contenente {string}",
  async function (_tenantType: TenantType) {
    return "pending";
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori con limit {int}",
  async function (_limit: number) {
    return "pending";
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori con offset {int}",
  async function (_offset: number) {
    return "pending";
  }
);

When(
  "l'utente richiede una operazione di listing degli erogatori filtrando per nome aderente {string}",
  function (_nomeAderente: string) {
    return "pending";
  }
);
