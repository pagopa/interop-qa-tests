import { When } from "@cucumber/cucumber";
import { TenantKind } from "../../../api/models";

When(
  "l'utente assegna a {string} l'attributo verificato precedentemente creato",
  async function (_tenantKind: TenantKind) {
    return "pending";
  }
);

When(
  "l'utente assegna a {string} l'attributo verificato precedentemente creato con data di scadenza nel futuro",
  async function (_tenantKind: TenantKind) {
    return "pending";
  }
);

When(
  "l'utente assegna a {string} l'attributo verificato precedentemente creato con data di scadenza nel passato",
  async function (_tenantKind: TenantKind) {
    return "pending";
  }
);
