import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  createClientAssertion,
  requestVoucher,
} from "../../../utils/commons";

When("l'utente richiede la generazione del voucher M2M", async function () {
  assertContextSchema(this, {
    clientId: z.string(),
    privateKey: z.string(),
    publicKey: z.string(),
  });

  const { publicKey, privateKey, clientId } = this;

  const clientAssertion = createClientAssertion({
    clientType: "API",
    clientId,
    publicKey,
    privateKey,
  });

  this.response = await requestVoucher({
    clientId,
    clientAssertion,
  });
});
