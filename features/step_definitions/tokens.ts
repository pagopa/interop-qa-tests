import { Given } from "@cucumber/cucumber"

export const API_ROOT_URL =
  "https://selfcare.dev.interop.pagopa.it/backend-for-frontend/0.0";

const TOKEN = {
  GSP: {
    admin: '',
  },
  PA1: {
    admin: '',
    "api,security": ''
  },
  Privato: {
    admin: ''
  }
} as const

type Party = keyof typeof TOKEN
type Role = "admin" | "admin" | "api,security" | "admin"

Given('l\'utente è un {string} di {string}', function(role: Role, party: Party) {
  //@ts-ignore
  this.token = TOKEN[party][role]
})
