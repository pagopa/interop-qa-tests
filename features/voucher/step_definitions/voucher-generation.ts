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

  const { publicKey, privateKey, clientId, purposeId } = this;
  const kid = calculateKidFromPublicKey(publicKey);

  const clientAssertion = createClientAssertion({
    kid,
    clientId,
    purposeId,
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
    const kid = calculateKidFromPublicKey(publicKey);

    const clientAssertion = createClientAssertion({
      kid,
      clientId,
      purposeId,
      privateKey,
      includeDigest: true,
    });

    const result = await requestVoucher({
      clientId,
      clientAssertion,
    });

    this.result = result;
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
