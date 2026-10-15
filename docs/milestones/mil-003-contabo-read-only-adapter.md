# Contabo read-only adapter

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-003 |
| CrossReference | [BC-001], [US-001], [MIL-002] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [d59571d] |

---

## Purpose

Decide whether the central claim of the design holds: one provider interface and one
capability model serve more than one provider. The slice adds Contabo as a second provider
behind the same port, for the same three read-only use cases as MIL-002, and shows that the
command-line interface (CLI) works the same way for both. A Go means the Product Owner
accepts the interface as provider-neutral, so that state-changing milestones can be built
on it.

## Deliverable

- The Python CLI configures and validates access to Contabo (UC-001), discovers capabilities
  and server options (UC-002) and lists and inspects servers, marking those not managed by
  this client (UC-007), with the same commands as for Proxmox VE.
- A decision record for the Contabo credentials and token handling.
- The design artifacts revised for a second provider.
- A mock Contabo application programming interface (API) and a provider-neutral contract
  test suite that runs against the fake, Proxmox VE and Contabo.
- A written result of a read-only live run against a real Contabo account.

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | All | Any missing or not Go |
| 2 | The same provider contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | All three | Any fails or is skipped |
| 3 | The CLI commands of US-001.01, US-001.02 and US-001.06 are each shown by an automated test with `--kind contabo` | All | Any not shown |
| 4 | No create, update, delete or action request exists in the Contabo adapter, and a test proves that only GET (and the token request) is sent | None found | Any found |
| 5 | A test shows that no Contabo credential is written to the configuration file or appears in an error text | Passes | Fails |
| 6 | The unit and contract tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 7 | A read-only live run against a real Contabo account is recorded and passes | Passes | Fails or not run |
| 8 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-002] accepted | The port, the capability model, the CLI and the test harness this slice extends |
| ADR-0002 and ADR-0003 accepted | Capability model and credential handling |
| A Contabo account with API access | Only for the live run (task 12); read-only calls cost nothing |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 2: provider-specific behaviour explicit through capability checks | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| Objective 4: no secrets in configuration | [BC-001] Objectives |
| US-001.01 Configure and validate provider access | [US-001] |
| US-001.02 Discover capabilities and server options | [US-001] |
| US-001.06 List and inspect servers | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-11-13 — four weeks from 2026-10-16, an assumption to be confirmed by S01. The Business
Case states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Decide the Contabo credentials and token handling | Contabo needs four values (client ID, client secret, API user, API password) and returns a short-lived bearer token; record in an ADR how `Credentials` carries several values, where the token lives and how an expired token is handled, keeping ADR-0003's rule that no secret is stored in configuration. | No | ADR |
| 2 | Revise the design artifacts for a second provider | Update the domain model, the dictionary, the design class diagram and the system sequence diagram lifecycle notes for multi-value credentials and a second adapter; the entity relationship diagram already allows the `CONTABO` provider kind. | No | DM, DICT, DCD, SSD |
| 3 | Make `Credentials` carry named values | Extend the domain value object to hold several named secret values that stay hidden in `repr` and cannot be persisted, with the unit tests; the Proxmox VE adapter keeps its single token. | No | DCD |
| 4 | Implement the Contabo adapter (read-only) | Obtain a token with the OAuth2 password grant, send `x-request-id` on every call, list and read instances, data centers and images, map them to the domain, keep the token in memory and obtain a new one once after a 401, and report 429 and 5xx as provider errors. | No | |
| 5 | Mock Contabo API and the provider-neutral contract suite | An in-process server answering the token request and the read endpoints, including a wrong password, an expired token, 429 and 500; and one contract suite parametrised over the fake, Proxmox VE and Contabo. | No | ADR-0001 |
| 6 | Credential handling for several values | Prompt for the four values, cache them as one platform credential-store entry, and keep them out of the configuration file and of every error text. | No | ADR-0003 |
| 7 | CLI support for Contabo | `provider add --kind contabo`, the provider resolver for the new kind, the same commands for capabilities, options, servers and server, and help text for the Contabo credential names. | Yes | UC-001, UC-002, UC-007 |
| 8 | End-to-end tests with `--kind contabo` | The acceptance criteria of US-001.01, US-001.02 and US-001.06 through the CLI against the mock, the no-secret test and the only-GET test. | No | US-001 |
| 9 | Live read-only smoke tests and the wiki page | Integration tests marked `integration`, skipped without credentials in environment variables, that only read; a wiki page in bash and PowerShell on how to run them with the Contabo credentials. | No | |
| 10 | Update the provider verification note | Mark the Contabo points (C1 to C20) that the mock and the live run confirm or contradict, and record what remains open. | No | |
| 11 | Review the artifacts and the code | Review records for the decision record, the revised design and the source code against the Python code checklist, and update the traceability matrix. | No | |
| 12 | Live run against a real Contabo account | Run the read-only smoke tests with a Contabo API user and record the result; no instance is created, changed or cancelled. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-002]: ./mil-002-read-only-slice-proxmox-cli.md
[d59571d]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d59571d87e5e2c2d19aa490850422180c720a45e
