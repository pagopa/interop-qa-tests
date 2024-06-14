import "dotenv/config";
import * as http from "http";
import * as https from "https";
import fs from "fs";
import { v4 as uuidv4 } from "uuid";
import _ from "lodash";
import { VerifyCommand, KMSClient, SignCommand } from "@aws-sdk/client-kms";
import { env } from "../configs/env";

const verboseMode =
  typeof process.env.ST_VERBOSE_MODE != "undefined" &&
  process.env.ST_VERBOSE_MODE === "1";

const sessionTokenHeaderTemplate = {
  typ: "at+jwt",
  alg: "WELL_KNOWN_ALG",
  use: "sig",
  kid: "WELL_KNOWN_KID",
};
const sessionTokenPayloadTemplate = {
  externalId: {
    origin: "VALUES_EXT_ID_ORIGIN",
    value: "VALUES_EXT_ID_VALUE",
  },
  "user-roles": "VALUES_USER_ROLES",
  selfcareId: "VALUES_SELFCARE_ID",
  organizationId: "VALUES_ORG_ID",
  // Data here are placeholders, the backend does not use them
  organization: {
    id: uuidv4(),
    name: "PagoPA S.p.A.",
    roles: [
      {
        partyRole: "MANAGER",
        role: "admin",
      },
    ],
    fiscal_code: "15376371009",
    ipaCode: "5N2TR557",
  },
  uid: "VALUES_UID",
  iss: "{{ENVIRONMENT}}.interop.pagopa.it",
  aud: "{{ENVIRONMENT}}.interop.pagopa.it/ui",
  nbf: 123,
  iat: 123,
  exp: 456,
  jti: "uuid",
};

logInfo(process.env);

const kmsClient = new KMSClient();

const config = {
  kms: {
    kid: null,
    alg: "RSASSA_PKCS1_V1_5_SHA_256",
  },
};

/**
 *
 * @param {*} stPayloadValuesFilePath File contenente i payload values dei tenant per cui bisogna generare i Session Token
 * @returns stOutputTokens SessionTokens JSON Object - A token for each tenant/role
 */
async function generateSessionTokens(stPayloadValuesFilePath) {
  // Step 1. Read session token payload values file
  logInfo("## Step 1. Read session token payload values file ##");
  const sessionTokenPayloadValues = JSON.parse(
    Buffer.from(fs.readFileSync(stPayloadValuesFilePath)).toString()
  );

  logInfo(`ST Payload Values: ${JSON.stringify(sessionTokenPayloadValues)}`);

  // Step 2. Parse well known
  logInfo("## Step 2. Parse well known ##");
  const wellKnownUrl = new URL(env.REMOTE_WELLKNOWN_URL);
  const { kid, alg } = await fetchWellKnown(
    wellKnownUrl.protocol.indexOf("https") >= 0,
    wellKnownUrl.toString()
  );
  if (!kid || !alg) {
    console.error("\tKid or alg not found.");
    return;
  }
  config.kms.kid = kid;
  logInfo(`\tGot kid ${kid} and alg ${alg}`);

  // Step 3. Generate STs header - Populate Session Token header from template
  logInfo(
    "## Step 3. Generate STs header - Populate Session Token header from template ##"
  );
  const stHeaderCompiled = Object.assign({}, sessionTokenHeaderTemplate, {
    kid,
    alg,
  });
  logInfo(`\tST Header Compiled: ${JSON.stringify(stHeaderCompiled)}`);

  // Step 4. Generate STs payload
  logInfo("## Step 4. Generate STs payload ##");
  logInfo("\tDefine time in seconds since epoch");
  const epochTimeSeconds = Math.round(new Date().getTime() / 1000);
  logInfo(`\tTime in seconds since epoch: ${epochTimeSeconds}`);

  logInfo("\tDefine token expiration time in seconds");
  const epochTimeExpSeconds =
    epochTimeSeconds + Number(env.SESSION_TOKENS_DURATION_SECONDS);
  logInfo(`\tExpiration Time in seconds: ${epochTimeExpSeconds}`);

  logInfo("\tDefine random UUID");
  const randomUUID = uuidv4();
  logInfo(`\tRandom UUID:: ${randomUUID}`);

  logInfo(`Populate Session Token payload from template`);
  let stPayloadCompiled = Object.assign({}, sessionTokenPayloadTemplate, {
    nbf: epochTimeSeconds,
    iat: epochTimeSeconds,
    exp: epochTimeExpSeconds,
    jti: randomUUID,
  });
  stPayloadCompiled = JSON.parse(
    JSON.stringify(stPayloadCompiled).replaceAll(
      "{{ENVIRONMENT}}",
      env.ENVIRONMENT
    )
  );
  logInfo(`\tST Payload Compiled: ${JSON.stringify(stPayloadCompiled)}`);

  logInfo("## Step 5. Generate unsigned STs ##");
  const unsignedSTs = unsignedStsGeneration(
    stHeaderCompiled,
    stPayloadCompiled,
    sessionTokenPayloadValues
  );
  logInfo(`\tUnsigned STs: ${JSON.stringify(unsignedSTs)}`);

  logInfo("## Step 6. Generate signed STs ##");
  const stOutputTokens = await signedStsGeneration(unsignedSTs);

  logInfo(
    `Session Token generation completed: ${JSON.stringify(stOutputTokens)}`
  );
  return stOutputTokens;
}

function logInfo(message) {
  if (verboseMode) {
    console.log(message);
  }
}

async function fetchWellKnown(isSecure, wellKnownUrl) {
  const jwksObj = await new Promise((resolve, reject) => {
    const httpMod = isSecure ? https : http;

    httpMod
      .get(wellKnownUrl, (res) => {
        const { statusCode } = res;
        const contentType = res.headers["content-type"];

        let error;
        // Any 2xx status code signals a successful response but
        // here we're only checking for 200.
        if (statusCode !== 200) {
          error = new Error("Request Failed.\n" + `Status Code: ${statusCode}`);
        } else if (!/^application\/json/.test(contentType)) {
          error = new Error(
            "Invalid content-type.\n" +
              `Expected application/json but received ${contentType}`
          );
        }
        if (error) {
          console.error(error.message);
          // Consume response data to free up memory
          res.resume();
          reject(error);
          return;
        }

        let rawData = "";

        res.setEncoding("utf8");
        res.on("data", (chunk) => {
          rawData += chunk;
        });
        res.on("end", () => {
          try {
            const parsedData = JSON.parse(rawData);
            resolve(parsedData);
          } catch (e) {
            console.error(e.message);
            reject(e);
          }
        });
      })
      .on("error", (e) => {
        reject(e);
      });
  });

  if (typeof jwksObj != "undefined" && jwksObj.keys && jwksObj.keys[0]) {
    return _.pick(jwksObj.keys[0], ["kid", "alg"]);
  }

  return null;
}

// Generate signed tokens from unsigned ones
async function signedStsGeneration(unsignedStValues) {
  const signedTokens = {};
  logInfo(`SignedTokenGeneration::START`);
  for (const tenant of Object.keys(unsignedStValues)) {
    logInfo(`\tBuilding token for tenant ${tenant}`);
    signedTokens[tenant] = {};

    for (const tenantRole of Object.keys(unsignedStValues[tenant])) {
      logInfo(`\tBuilding token for role ${tenantRole}`);

      const currentUnsignedJwt = unsignedStValues[tenant][tenantRole];
      const { signedToken, signature } = await kmsSign(currentUnsignedJwt);

      if (!(await kmsVerify(currentUnsignedJwt, signature))) {
        throw Error(
          "\tSigned Token generation process failed to verify signature"
        );
      }

      signedTokens[tenant][tenantRole] = signedToken;
    }
  }
  logInfo(`SignedTokenGeneration::END`);

  return signedTokens;
}

function unsignedStsGeneration(
  stHeaderCompiled,
  stPayloadCompiled,
  stPayloadValues
) {
  try {
    logInfo(
      `unsignedStsGeneration::Phase1:START: Build roles dynamic substitutions`
    );
    const stsSubOutput = {};
    for (const tenant of Object.keys(stPayloadValues)) {
      logInfo(
        `\tunsignedStsGeneration::Phase1: Build roles substitutions for tenant ${tenant}`
      );
      stsSubOutput[tenant] = {};

      const organizationId =
        stPayloadValues[tenant]?.organizationId?.[env.ENVIRONMENT];

      const selfcareId = stPayloadValues[tenant]?.selfcareId;
      const externalId = stPayloadValues[tenant]?.externalId;

      const userRoles = stPayloadValues[tenant]?.["user-roles"];

      if (!organizationId || !selfcareId || !externalId || !userRoles) {
        throw Error(
          `Missing values for tenant ${tenant} in env ${env.ENVIRONMENT}`
        );
      }

      for (const interopRole of Object.keys(userRoles)) {
        logInfo(
          `\tunsignedStsGeneration::Phase1: Start dynamic substition for role ${interopRole}`
        );
        const uid = userRoles[interopRole];

        stsSubOutput[tenant][interopRole] = Object.assign(
          {},
          stPayloadCompiled,
          {
            externalId,
            uid,
            selfcareId,
            organizationId,
            "user-roles": interopRole,
          }
        );
      }
    }
    logInfo(
      `unsignedStsGeneration::Phase1:END: Build roles dynamic substitutions`
    );

    logInfo(
      `unsignedStsGeneration::Phase2:START: Build base64 header and body for each tenant/role`
    );
    const base64Header = b64UrlEncode(JSON.stringify(stHeaderCompiled));
    logInfo("\tunsignedStsGeneration::Phase2: Build base64 header done");

    const stOutputIntermediate = {};
    for (const tenant of Object.keys(stsSubOutput)) {
      logInfo(
        `\tunsignedStsGeneration::Phase2: Build partial JWT for ${tenant}`
      );
      stOutputIntermediate[tenant] = {};

      for (const interopRole of Object.keys(stsSubOutput[tenant])) {
        logInfo(
          `\tunsignedStsGeneration::Phase2: Build partial JWT for tenant ${tenant} role ${interopRole}`
        );
        const base64Role = b64UrlEncode(
          JSON.stringify(stsSubOutput[tenant][interopRole])
        );
        const poJwtForRole = `${base64Header}.${base64Role}`;

        stOutputIntermediate[tenant][interopRole] = poJwtForRole;
      }
    }
    logInfo(
      `unsignedStsGeneration::Phase2:END: Build base64 header and body for each tenant/role`
    );

    console.log(JSON.stringify(stsSubOutput, null, 2));

    return stOutputIntermediate;
  } catch (ex) {
    console.error(ex);
    throw ex;
  }
}

// KMS Wrappers
async function kmsSign(serializedToken) {
  if (!serializedToken) {
    throw Error(`kmsSign: invalid input - missing`);
  }

  // SignCommandInput
  const signCommandParams = {
    KeyId: config.kms.kid,
    Message: new TextEncoder().encode(serializedToken),
    SigningAlgorithm: config.kms.alg,
  };

  const signCommand = new SignCommand(signCommandParams);
  const response = await kmsClient.send(signCommand);
  const responseSignature = response.Signature;

  if (!responseSignature) {
    throw Error("JWT Signature failed. Empty signature returned");
  }

  const kmsSignature = b64ByteUrlEncode(responseSignature);

  return {
    signedToken: `${serializedToken}.${kmsSignature}`,
    signature: responseSignature,
  };
}

async function kmsVerify(unsignedToken, signature) {
  if (!unsignedToken || !signature) {
    throw Error(`kmsVerify: invalid input - missing`);
  }

  // VerifyCommandInput
  const commandParams = {
    KeyId: config.kms.kid,
    Message: new TextEncoder().encode(unsignedToken),
    SigningAlgorithm: config.kms.alg,
    Signature: signature,
  };
  const verifyCommand = new VerifyCommand(commandParams);
  const response = await kmsClient.send(verifyCommand);

  if (!response.SignatureValid) {
    throw Error("JWT Verify Signature failed");
  }

  return response.SignatureValid;
}

// Encoding utilities
/**
 * Encode a byte array to a url encoded base64 string, as specified in RFC 7515 Appendix C
 */
function b64ByteUrlEncode(b) {
  return bufferB64UrlEncode(Buffer.from(b));
}

/**
 * Encode a string to a url encoded base64 string, as specified in RFC 7515 Appendix C
 */
function b64UrlEncode(str) {
  return bufferB64UrlEncode(Buffer.from(str, "binary"));
}

function bufferB64UrlEncode(b) {
  return b
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

// Export section
export { generateSessionTokens };
