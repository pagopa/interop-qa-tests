# interop-qa-tests

This repository is used as a GitHub Actions trigger/orchestration layer for Interop QA operations on AWS.

End-to-end tests are executed from external repositories (for example `pagopa/pn-b2b-client`) through workflows defined here.

## What this repo does

- Orchestrates ephemeral self-hosted runners on AWS.
- Runs optional data preparation tasks (DB restore/purge, Kubernetes scaling, cronjobs).
- Triggers Java-based QA suites in external repositories.
- Handles teardown/cleanup of the execution runner.

## Main workflows

- `.github/workflows/qa.yaml`: QA orchestration for `es1-*` environments (data preparation + Java test handoff).
- `.github/workflows/tracing-qa.yaml`: tracing QA orchestration for `tracing-*` environments.
