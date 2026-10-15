# Read-only slice: Proxmox VE with the Python CLI

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-002 |
| CrossReference | [BC-001], [US-001], [MIL-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [65fb60d] |

---

## Purpose

Decide whether the product's foundations work end to end before any action that
changes state is built. The slice proves provider access, the common provider
interface with its capability model, the per-client configuration file and the
credential handling, using only read-only calls against Proxmox VE and the
Python command-line interface (CLI). A Go means the Product Owner accepts the
architecture the later milestones build on.

## Deliverable

- A working Python 3.13 CLI that, against Proxmox VE, configures and validates
  provider access (UC-001), discovers capabilities and server options (UC-002)
  and lists and inspects servers, marking those not managed by this client
  (UC-007).
- The design artifacts for these three use cases: domain model, system sequence
  diagrams, operation contracts, design class diagram and the entity
  relationship diagram of the configuration file.
- A mock Proxmox VE API and a continuous integration (CI) workflow that runs
  the unit and contract tests.
- A written result of the integration run against the Proxmox VE virtual
  machine (VM).

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The design artifacts of this milestone exist and each has a `Go` review record | All | Any missing or not Go |
| 2 | The acceptance criteria of US-001.01, US-001.02 and US-001.06 are each shown by an automated test | All | Any not shown |
| 3 | The unit and contract tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 4 | The integration run against the Proxmox VE VM is recorded and passes | Passes | Fails or not run |
| 5 | A test shows that no secret is written to the configuration file | Passes | Fails |
| 6 | No create, update or delete call exists in the code of this slice | None found | Any found |
| 7 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-001] accepted | Use cases, provider facts and the four decisions this slice implements |
| ADR-0001 to ADR-0004 accepted | Test strategy, capability model and credential decisions |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 2: provider-specific behaviour explicit through capability checks | [BC-001] Objectives |
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

2026-11-26 — four weeks from 2026-10-29, an assumption to be confirmed by S01.
The Business Case states no deadline, so there is no constraint to conflict
with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Set up the Python submodule | Initialise the `iac-node-forge-py` repository as a submodule of this project with the folder structure of the clean architecture skill, a Python 3.13 toolchain, a formatter and a linter, so every later task has a place to put code. | No | |
| 2 | Domain model for provider access | Describe the concepts of provider, credential reference, capability, target and server (managed or not managed by this client) in the domain model, using the terms of the use cases UC-001, UC-002 and UC-007. | No | DM |
| 3 | System sequence diagrams | Draw the interaction between DevOps and the product, and between the product and the provider, for UC-001, UC-002 and UC-007. | No | SSD |
| 4 | Operation contracts | Write the contracts for the state-changing system operations of this slice: saving a provider configuration, saving a credential reference and recording a server as managed. | No | OC |
| 5 | Design class diagram and provider interface | Design the common provider interface and capability model of ADR-0002, the use case classes and the ports for configuration and credentials, so the domain does not import infrastructure. | No | DCD |
| 6 | Configuration file design | Define the JSON Lines (JSONL) records of the per-client configuration: provider, endpoint, credential reference, managed servers; no secrets (ADR-0003). | No | ERD |
| 7 | Implement the provider interface and capability model | Python code for the provider port, the capability set and the result types, with unit tests that need no network. | No | DCD |
| 8 | Implement the Proxmox VE adapter (read-only) | Authentication by ticket and by API token, listing nodes, storage and cluster resources, and reporting capabilities, against the documented Proxmox VE API. | No | |
| 9 | Implement configuration and credential handling | JSONL reading and writing without secrets, a prompt for secrets and an optional cache in the platform credential store, as ADR-0003 decides. | No | |
| 10 | Implement the CLI commands | The commands for configuring and validating access, discovering capabilities and listing and inspecting servers, with a clear message when a provider is unreachable. | Yes | UC-001, UC-002, UC-007 |
| 11 | Mock Proxmox VE API and contract tests | An in-process HTTP server that answers like the documented endpoints, including failures such as an expired token, as ADR-0001 decides. | No | ADR-0001 |
| 12 | CI workflow | A Gitea workflow that installs Python 3.13 on the runner image (which ships 3.12), runs linters, unit tests and contract tests. | No | ADR-0001 |
| 13 | Integration run on the Proxmox VE VM | Run the CLI against the VM on the Product Owner's machine and record the result, including the self-signed certificate decision. | No | |
| 14 | Review the artifacts and the code | Review records for the design artifacts and the source code against the Python code checklist, and update the traceability matrix. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-001]: ./mil-001-use-case-baseline.md
[65fb60d]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/65fb60dc57f5bb63307d4e905f5f49f567b98f28
