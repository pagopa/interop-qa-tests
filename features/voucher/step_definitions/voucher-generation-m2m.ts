import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  createClientAssertion,
  createKeyPairPEM,
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

When(
  "l'utente richiede la generazione del voucher M2M con una chiave associata a nessun client",
  async function () {
    assertContextSchema(this, {
      clientId: z.string(),
    });

    const { publicKey, privateKey } = createKeyPairPEM();

    const clientAssertion = createClientAssertion({
      clientType: "API",
      clientId: this.clientId,
      publicKey: publicKey as string,
      privateKey: privateKey as string,
    });

    this.response = await requestVoucher({
      clientId: this.clientId,
      clientAssertion,
    });
  }
);
