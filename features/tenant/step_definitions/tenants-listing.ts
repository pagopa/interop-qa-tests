import { When } from "@cucumber/cucumber";

When(
  "l'utente richiede una operazione di listing degli aderenti limitata a {int}",
  async function (count: number) {}
);

When(
  "l'utente richiede una operazione di listing degli aderenti filtrando per la keyword {string}",
  async function (keyword: string) {}
);

When(
  "l'utente richiede una operazione di listing degli aderenti senza ricevere risultato",
  async function () {}
);
