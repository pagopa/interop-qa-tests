import { Given, Then, When } from "@cucumber/cucumber";

Given("{string} ha già inserito una mail di contatto", async function () {});

When(
  "l'utente richiede un operazione di aggiunta di una mail di contatto con description",
  async function () {}
);

When(
  "l'utente richiede un operazione di aggiunta di una mail di contatto senza description",
  async function () {}
);

When(
  "l'utente richiede un operazione di aggiornamento di quella mail di contatto senza description",
  async function () {}
);

Then(
  "si ottiene status code 200 e la mail è stata aggiornata e non aggiunta",
  async function () {}
);
