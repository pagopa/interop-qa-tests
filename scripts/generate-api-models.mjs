import { generateApi } from 'swagger-typescript-api'
import path from 'path'

const openApiSpecificationFileUrl =
  'https://raw.githubusercontent.com/pagopa/interop-be-backend-for-frontend/1.0.x/src/main/resources/interface-specification.yml'

const apiFolderPath = path.resolve('./api/')

generateApi({
  name: 'models.ts',
  url: openApiSpecificationFileUrl,
  output: apiFolderPath,
  generateClient: true,
  httpClientType: "axios",
  generateUnionEnums: true,
  extractRequestParams: true,
  extractRequestBody: true,
  generateRouteTypes: true,
}).catch((e) => console.error(e))
