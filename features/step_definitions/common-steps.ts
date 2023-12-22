import { Given } from "@cucumber/cucumber";
import { generateSessionTokens } from "../../utils/session-tokens";

type Party = "GSP" | "PA1" | "Privato";
type Role = "admin" | "api,security";

Given(
  "l'utente è un {string} di {string}",
  async function (role: Role, party: Party) {
    const tokens = await generateSessionTokens(
      process.env.TENANT_IDS_FILE_PATH
    );
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    this.token = tokens[party][role];
  }
);
