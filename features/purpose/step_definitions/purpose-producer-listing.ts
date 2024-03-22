import { Given, Then, When } from "@cucumber/cucumber";

When(
  "l'utente erogatore richiede una operazione di listing delle finalità limitata alle prime {int} finalità",
  async function () {}
);

Then(
  "si ottiene status code {int} e la lista di {int} finalità",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità con offset {int}",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità sui propri e-service",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrata per fruitore {string}",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrata per il primo e-service",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità in stato {string}",
  async function () {}
);

Given(
  "un {string} di {string} ha già creato {int} finalità in stato {string} per quell'e-service contenente la keyword {string}",
  async function () {}
);

When(
  "l'utente erogatore richiede una operazione di listing delle finalità filtrando per la keyword {string}",
  async function () {}
);
