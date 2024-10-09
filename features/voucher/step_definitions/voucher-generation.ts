import { Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
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

  const { publicKey, privateKey, clientId, purposeId } = this;

  const clientAssertion = createClientAssertion({
    clientType: "CONSUMER",
    clientId,
    purposeId,
    publicKey,
    privateKey,
  });

  this.response = await requestVoucher({
    clientId,
    clientAssertion,
  });
});

When(
  "l'utente richiede la generazione del voucher con digest",
  async function () {
    assertContextSchema(this, {
      clientId: z.string(),
      purposeId: z.string(),
      privateKey: z.string(),
      publicKey: z.string(),
    });

    const { publicKey, privateKey, clientId, purposeId } = this;

    const clientAssertion = createClientAssertion({
      clientType: "CONSUMER",
      clientId,
      purposeId,
      publicKey,
      privateKey,
      includeDigest: true,
    });

    this.response = await requestVoucher({
      clientId,
      clientAssertion,
    });
  }
);

When(
  "l'utente richiede la generazione del voucher indicando il primo client ma con la chiave caricata nel secondo",
  async function () {
    assertContextSchema(this, {
      clientId: z.string(),
      purposeId: z.string(),
      newClientPrivateKey: z.string(),
      newClientPublicKey: z.string(),
    });

    const { newClientPublicKey, newClientPrivateKey, clientId, purposeId } =
      this;

    const clientAssertion = createClientAssertion({
      clientType: "CONSUMER",
      clientId,
      purposeId,
      publicKey: newClientPublicKey,
      privateKey: newClientPrivateKey,
    });

    this.response = await requestVoucher({
      clientId,
      clientAssertion,
    });
  }
);

Then("si ottiene la corretta generazione del voucher", async function () {
  assertContextSchema(this, {
    response: z.object({
      data: z.object({
        access_token: z.string(),
        expires_in: z.number(),
        token_type: z.literal("Bearer"),
      }),
      status: z.literal(200),
    }),
  });
});
