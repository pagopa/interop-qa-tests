import { Given } from "@cucumber/cucumber";
import { EServiceTechnology } from "../../../api/models";

Given(
  "un {string} di {string} ha già creato un e-service con un descrittore in stato DRAFT e tecnologia {string}",
  async function (role: Role, party: Party, tecnology: EServiceTechnology) {}
);
