# interop-qa-tests

## ENVs

The following values are used to run the test suite from the local, targeting the DEV environment:

```
BFF_BASE_URL="https://selfcare.dev.interop.pagopa.it/0.0/backend-for-frontend"
ENVIRONMENT="dev"
REMOTE_WELLKNOWN_URL="https://www.dev.interop.pagopa.it/.well-known/jwks.json"
SESSION_TOKENS_DURATION_SECONDS=2700
TENANTS_IDS_FILE_PATH="./data/dev/tenants-ids.json"
MAX_POLLING_TRIES=50
POLLING_SLEEP_TIME=100
```

## Session tokens module

The module exports `async generateSessionTokens(string)` which takes the tenants ids file path as input and
returns a JSON object containing a valid session token for each tenant kind/role combination.

Usage example:

```javascript
import { generateSessionTokens } from "./utils/session-tokens.js";

const sessionTokens = await generateSessionTokens(
  process.env.TENANTS_IDS_FILE_PATH
);
```

Output example:

```json
{
  "gsp": {
    "admin": "jwt...",
    "api": "jwt..."
  }
}
```

## Tags

Tests are labeled with the following special tags:

- ```@wait_for_fix```: test bug affected, waiting for resolution, don't execute in test suite
- ```@resource_intensive```: test resource consuming, to run only in environment with high performance