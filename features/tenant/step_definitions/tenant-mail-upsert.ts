import assert from "assert";
import { Given, Then, When } from "@cucumber/cucumber";
import { z } from "zod";
import { dataPreparationService } from "../../../services/data-preparation.service";
import {
  TenantType,
  assertContextSchema,
  getAuthorizationHeader,
  getOrganizationId,
  getRandomInt,
  makePolling,
  sleep,
} from "../../../utils/commons";
import { apiClient } from "../../../api";

Given(
  "{string} ha già inserito una mail di contatto",
  async function (tenantType: TenantType) {
    assertContextSchema(this, { token: z.string() });
    this.email = `${getRandomInt()}test@pagopa.it`;
    const tenantId = getOrganizationId(tenantType);
    await dataPreparationService.addEmailToTenant(this.token, tenantId, {
      address: this.email,
      description: "test description",
    });
  }
);

When(
  "l'utente richiede una operazione di aggiunta di una mail di contatto con description",
  async function () {
    assertContextSchema(this, { token: z.string(), tenantType: TenantType });
    const tenantId = getOrganizationId(this.tenantType);
    this.response = await apiClient.tenants.addTenantMail(
      tenantId,
      {
        kind: "CONTACT_EMAIL",
        address: `${this.TEST_SEED}@pagopa.it`,
        description: "test description",
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di aggiunta di una mail di contatto senza description",
  async function () {
    assertContextSchema(this, { token: z.string(), tenantType: TenantType });
    this.email = `${this.TEST_SEED}${getRandomInt()}@pagopa.it`;
    const tenantId = getOrganizationId(this.tenantType);
    this.response = await apiClient.tenants.addTenantMail(
      tenantId,
      {
        kind: "CONTACT_EMAIL",
        address: this.email,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di aggiornamento della mail di contatto senza description",
  async function () {
    assertContextSchema(this, { token: z.string(), tenantType: TenantType });
    this.email = `${this.TEST_SEED}}@pagopa.it`;
    this.tenantId = getOrganizationId(this.tenantType);
    this.response = await apiClient.tenants.addTenantMail(
      this.tenantId,
      {
        kind: "CONTACT_EMAIL",
        address: this.email,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

When(
  "l'utente richiede una operazione di aggiunta della stessa mail di contatto già inserita",
  async function () {
    assertContextSchema(this, {
      token: z.string(),
      email: z.string(),
      tenantType: TenantType,
    });
    const tenantId = getOrganizationId(this.tenantType);
    this.response = await apiClient.tenants.addTenantMail(
      tenantId,
      {
        kind: "CONTACT_EMAIL",
        address: this.email,
      },
      getAuthorizationHeader(this.token)
    );
  }
);

Then(
  "si ottiene status code {int} e la mail è stata aggiornata e non aggiunta",
  async function (statusCode: number) {
    assertContextSchema(this, {
      tenantId: z.string(),
      email: z.string(),
      response: z.object({
        status: z.number(),
      }),
    });

    let updatedMail;
    await makePolling(
      () =>
        apiClient.tenants.getTenant(
          this.tenantId,
          getAuthorizationHeader(this.token)
        ),
      (res) => {
        updatedMail = res.data.contactMail?.address;
        return updatedMail === this.email;
      }
    );
    assert.equal(this.response.status, statusCode);
    assert.equal(updatedMail, this.email);
  }
);

Then("aspetta che si aggiorni il readmodel", async function () {
  await sleep(3000);
});
