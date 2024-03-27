import { Then, When } from "@cucumber/cucumber";

When(
  "l'utente richiede il template dell'analisi del rischio",
  async function () {}
);

Then(
  "si ottiene status code {int} e il template in versione {string}",
  async function (statusCode: number, expectedVersion: string) {}
);
