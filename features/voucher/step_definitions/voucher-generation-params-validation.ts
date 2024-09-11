import { randomUUID } from "crypto";
import { When } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  createClientAssertion,
  requestVoucher,
} from "../../../utils/commons";

When(
  "l'utente richiede la generazione del voucher con il parametro {string} diverso da quello atteso",
  async function (param: string) {
    assertContextSchema(this, {
      clientId: z.string(),
      purposeId: z.string(),
      privateKey: z.string(),
      publicKey: z.string(),
    });

    const tParam = z
      .union([z.literal("client_assertion_type"), z.literal("grant_type")])
      .parse(param);

    const { publicKey, privateKey, clientId, purposeId } = this;

    const clientAssertion = createClientAssertion({
      clientId,
      purposeId,
      publicKey,
      privateKey,
    });

    const key =
      tParam === "client_assertion_type" ? "clientAssertionType" : "grantType";

    this.response = await requestVoucher({
      clientId,
      clientAssertion,
      [key]: "unknown",
    });
  }
);

When(
  "l'utente richiede la generazione del voucher valorizzando il parametro client_id con un valore diverso dal claim sub nella client assertion",
  async function () {
    assertContextSchema(this, {
      clientId: z.string(),
      purposeId: z.string(),
      privateKey: z.string(),
      publicKey: z.string(),
    });

    const { publicKey, privateKey, clientId, purposeId } = this;

    const clientAssertion = createClientAssertion({
      clientId,
      purposeId,
      publicKey,
      privateKey,
    });

    this.response = await requestVoucher({
      clientId: randomUUID(),
      clientAssertion,
    });
  }
);

When(
  "l'utente richiede la generazione del voucher inserendo una client assertion come JWT non valida",
  async function () {
    assertContextSchema(this, {
      clientId: z.string(),
    });

    this.response = await requestVoucher({
      clientId: randomUUID(),
      clientAssertion: "unknown",
    });
  }
);
