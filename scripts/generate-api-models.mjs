import path from "path";
import { generateApi } from "swagger-typescript-api";

const openApiSpecificationFileUrl =
  "https://raw.githubusercontent.com/pagopa/interop-be-monorepo/refs/heads/main/packages/api-clients/open-api/bffApi.yml";

const apiFolderPath = path.resolve("./api/");

generateApi({
  name: "models.ts",
  url: openApiSpecificationFileUrl,
  output: apiFolderPath,
  generateClient: true,
  httpClientType: "axios",
  generateUnionEnums: true,
  extractRequestParams: true,
  extractRequestBody: true,
  generateRouteTypes: true,
}).catch((e) => console.error(e));
