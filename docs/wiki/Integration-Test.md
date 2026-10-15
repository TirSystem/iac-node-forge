**English**

# Real Proxmox VE integration test

The Python client has two kinds of tests. The normal tests run everywhere, including in
Gitea CI, against an in-process mock of the Proxmox VE API. The **integration tests** run
the same read-only adapter against a **real** Proxmox VE, so they confirm what a mock
cannot: the API-token header and the real shape of the answers.

The integration tests are skipped unless `PVE_TOKEN` is set, so they never run by
accident and never run in CI.

## The three parts

| Part | What you do | Page |
| --- | --- | --- |
| 1 | Start a Proxmox VE container, set a password, create an API token | [Set up the container](Integration-Test-Set-Up) |
| 2 | Run `pytest -m integration` against it | [Run the tests](Integration-Test-Run) |
| 3 | Stop the container and clear the variables | [Take it down](Integration-Test-Take-Down) |

## Before you start

- **Windows with Docker Desktop** and **PowerShell 7**. The commands on these pages are
  PowerShell; on Linux or macOS use the same commands with `export NAME=value` for
  `$env:NAME = 'value'`.
- **Python 3.13** and the repository `iac-node-forge-py` (the submodule folder of the main
  project works).
- **A machine you control.** The container is third-party and runs privileged. Use it
  for local development only, never in CI and never on a shared host.

## What the tests do

All tests are read-only. No create, update or delete request is sent.

| Test | Shows |
| --- | --- |
| validate access with the token | The token header is accepted |
| validate access with a wrong token | A failed result, not an exception |
| capabilities | No write capability is declared |
| server options `node` | At least one node is listed |
| server options `storage` | A list (possibly empty) is returned |
| list servers | Servers are returned, none marked as managed |
| get an absent server | A not-found error |
| error text | The token secret never appears in an error |

## Rules for secrets

- The password and the token live only in environment variables of your PowerShell
  session. Do not write them in a file, a commit or a chat.
- Choose a new password for every container; it is a throw-away value.
