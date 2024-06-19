import { Given, When } from "@cucumber/cucumber";
import { TenantKind } from "../../../api/models";

Given(
  "{string} verifica l'attributo verificato a {string} con una data di scadenza nel futuro",
  async function (_tenantKind: TenantKind) {
    return "pending";
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel futuro",
  async function () {
    return "pending";
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo rimuovendo la data di scadenza",
  async function () {
    return "pending";
  }
);

When(
  "l'utente richiede l'aggiornamento di quell'attributo con una data di scadenza nel passato",
  async function () {
    return "pending";
  }
);
