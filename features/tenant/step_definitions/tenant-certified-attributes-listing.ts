import { When } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

When(
  "l'utente richiede una operazione di listing degli attributi certificati posseduti da {string}",
  function (_tenantType: TenantType) {
    return "pending";
  }
);
