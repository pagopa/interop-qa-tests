import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  calculateKidFromPublicKey,
  createClientAssertion,
  requestVoucher,
} from "../../../utils/commons";

When("l'utente richiede la generazione del voucher", async function () {
  assertContextSchema(this, {
    clientId: z.string(),
    purposeId: z.string(),
    privateKey: z.string(),
    publicKey: z.string(),
  });

  const clientAssertion = createClientAssertion({
    kid: calculateKidFromPublicKey(this.publicKey),
    clientId: this.clientId,
    purposeId: this.purposeId,
    privateKey: this.privateKey,
  });

  const result = await requestVoucher({
    clientId: this.clientId,
    clientAssertion,
  });

  console.log(result);
});

Then("si ottiene la corretta generazione del voucher", function () {
  console.log("DOne");
});
