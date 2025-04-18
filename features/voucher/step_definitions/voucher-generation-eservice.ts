import { Given, Then } from "@cucumber/cucumber";
import { z } from "zod";
import {
  assertContextSchema,
  getToken,
  TenantType,
} from "../../../utils/commons";
import { dataPreparationService } from "../../../services/data-preparation.service";

Given(
  "{string} ha già una nuova versione in stato DRAFT per quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
    });
    const token = await getToken(tenantType);

    const descriptorId = await dataPreparationService.createNextDraftDescriptor(
      token,
      this.eserviceId
    );
    this.descriptorId = descriptorId;

    await dataPreparationService.bringDescriptorToGivenState({
      token,
      eserviceId: this.eserviceId,
      descriptorId,
      descriptorState: "DRAFT",
    });
  }
);

Given(
  "{string} ha già attivato nuovamente quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      descriptorId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activateDescriptor(
      token,
      this.eserviceId,
      this.descriptorId
    );
  }
);

Given(
  "{string} ha già sospeso la vecchia versione di quell'e-service",
  async function (tenant: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      oldDescriptorId: z.string(),
    });
    const token = await getToken(tenant);
    this.response = await dataPreparationService.suspendDescriptor(
      token,
      this.eserviceId,
      this.oldDescriptorId
    );
  }
);

Given(
  "{string} ha già attivato nuovamente la vecchia versione quell'e-service",
  async function (tenantType: TenantType) {
    assertContextSchema(this, {
      eserviceId: z.string(),
      oldDescriptorId: z.string(),
    });

    const token = await getToken(tenantType);

    await dataPreparationService.activateDescriptor(
      token,
      this.eserviceId,
      this.oldDescriptorId
    );
  }
);

Then(
  "la richiesta di generazione del Voucher non va a buon fine per il parametro grant_type",
  async function () {
    assertContextSchema(this, {
      response: z.object({
        data: z
          .object({
            errors: z.tuple([
              z.object({
                code: z.literal("015-9000"),
                detail: z.literal(
                  'Invalid parameter found - [Path \'/grant_type\'] Instance value ("unknown") not found in enum (possible values: ["client_credentials"])'
                ),
              }),
            ]),
            status: z.literal(400),
            title: z.literal(
              "The request contains bad syntax or cannot be fulfilled."
            ),
            type: z.literal("about:blank"),
          })
          .or(
            z.object({
              errors: z.tuple([
                z.object({
                  code: z.literal("9999"),
                  detail: z.literal(
                    'Validation error: Invalid literal value, expected "client_credentials" at "grant_type"'
                  ),
                }),
              ]),
              status: z.literal(400),
              title: z.literal("Bad request"),
              type: z.literal("about:blank"),
            })
          ),
      }),
    });
  }
);

Then(
  "la richiesta di generazione del Voucher non va a buon fine",
  async function () {
    assertContextSchema(this, {
      response: z.object({
        data: z.object({
          correlationId: z.string().uuid(),
          errors: z.tuple([
            z.object({
              code: z.literal("015-0008"),
              detail: z.literal(
                "Unable to generate a token for the given request"
              ),
            }),
          ]),
          status: z.literal(400),
          title: z.literal(
            "The request contains bad syntax or cannot be fulfilled."
          ),
          type: z.literal("about:blank"),
        }),
      }),
    });
  }
);
