import { Then, When } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli attributi dichiarati posseduti da {string}",
  function (_tenantType: TenantType) {
    return "pending";
  }
);

Then(
  "si ottiene status code 200 e la lista degli attributi contenente l'attributo dichiarato",
  function () {
    return "pending";
  }
);
