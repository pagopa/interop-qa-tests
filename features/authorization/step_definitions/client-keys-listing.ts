import { Given, Then, When } from "@cucumber/cucumber";
import { TenantType } from "../../../utils/commons";

Given(
  "un {string} di {string} ha caricato una chiave pubblica in quel client",
  (_role: string, _client: string) => {
    console.log("TODO");
  }
);

When(
  "l'utente richiede una operazione di listing delle chiavi di quel client",
  () => {
    console.log("TODO");
  }
);

Then(
  "si ottiene status code {int} e la lista di {int} chiavi",
  (_statusCode: number, _numKeys: number) => {
    console.log("TODO");
  }
);

When(
  "l'utente richiede una operazione di listing delle chiavi di quel client create dall'utente {string}",
  (_tenantType: TenantType) => {
    console.log("TODO");
  }
);
