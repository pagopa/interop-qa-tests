# interop-qa-tests

## ENVs
The following values are used to run the test suite from the local, targeting the DEV environment:

```
ENVIRONMENT="dev"
REMOTE_WELLKNOWN_URL="https://www.dev.interop.pagopa.it/.well-known/jwks.json"
SESSION_TOKENS_DURATION_SECONDS=1800
TENANTS_IDS_FILE_PATH="./data/dev/tenants-ids.json"
```

## Session tokens module

The module exports `async generateSessionTokens(string)` which takes the tenants ids file path as input and
returns a JSON object containing a valid session token for each tenant kind/role combination.

Usage example:

```javascript
 import { generateSessionTokens } from "./utils/session-tokens.js";

const sessionTokens = await generateSessionTokens(process.env.TENANTS_IDS_FILE_PATH);
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
