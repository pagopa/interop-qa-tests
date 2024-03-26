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
CUCUMBER_OPTS_PARALLEL=5
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

- `@wait_for_fix`: test bug affected, waiting for resolution, don't execute in test suite
- `@resource_intensive`: test resource consuming, to run only in environment with high performance

## Running test

This test suite supports nodejs and [bun](https://bun.sh/docs) runtime. To run with bun simply use the prefix "bun" to npm script.

To run all tests:

```shell
pnpm test
```

To run all tests with bun:

```shell
pnpm bun:test
```

### Test script

```shell
# Run all test, excluding test labeled with "special" tag: @wait_for_fix, @resouce_intensive
pnpm test:ready
```

```shell
# Run only tagged test
pnpm test:tags "@some_useful_tag"
```

```shell
# Run only specific module test, excluding special tag
pnpm test:catalog
```

```shell
# Run only test waiting for fix
pnpm test:tags "@wait_for_fix"
```

### Validate feature file and step implementation

```shell
pnpm check-steps
```

```shell
pnpm check-steps:usage
```
