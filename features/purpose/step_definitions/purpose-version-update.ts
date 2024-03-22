import { Given, When } from "@cucumber/cucumber";

Given(
  "l'utente non ha finalità in stato WAITING_FOR_APPROVAL",
  async function () {}
);

When(
  "l'utente aggiorna la stima di carico per quella finalità",
  async function () {}
);

Given(
  "l'utente ha già una finalità in stato WAITING_FOR_APPROVAL",
  async function () {
    // TODO invece di implementare questo nuovo Given, valutare se riutilizzare questo:
    // Given un "admin" di "PA1" ha già creato 1 finalità in stato "WAITING_FOR_APPROVAL" per quell'eservice
    // TODO controllare se quel Given gestisce anche il WAITING_FOR_APPROVAL
  }
);
