import { Then, When } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli attributi verificati posseduti da {string}",
  function (_tenantType: TenantType) {
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo verificato da {string}",
  function (_tenantType: TenantType) {
    return "pending";
  }
);
