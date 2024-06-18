import { Then, When } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli attributi certificati posseduti",
  async function () {
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo assegnato da {string} e l'attributo IPA comune",
  async function (_tenantType: TenantType) {
    return "pending";
  }
);
