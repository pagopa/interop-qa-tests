import { Given } from "@cucumber/cucumber";

const TOKEN = {
  GSP: {
    admin: "",
  },
  PA1: {
    admin: "",
    "api,security": "",
  },
  Privato: {
    admin: "",
  },
} as const;

type Party = keyof typeof TOKEN;
type Role = "admin" | "admin" | "api,security" | "admin";

Given(
  "l'utente è un {string} di {string}",
  function (role: Role, party: Party) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    this.token = TOKEN[party][role];
  }
);
