# Provisioning

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-005 |
| CrossReference | [BC-001], [US-001], [MIL-004] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Deprecated | Jens Tirsvad Nielsen | AI as stand-in for S02 | Accepted after RC-067 (autonomous mode, stand-in) | [2034b4b] |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Go decision: all ten criteria met (RC-080); stand-in decision, open to challenge | [dad18d0] |

---

## Purpose

Decide whether the capability model holds for the first action that creates something and
may cost money. The slice adds the desired server configuration (UC-003) and the provisioning
of a server from it (UC-004), with the operation tracking of MIL-004, for Proxmox VE and
Contabo through the command-line interface (CLI). The two providers differ most in what a
creation means: Proxmox VE creates a virtual machine or container on a node and answers with a
task, Contabo creates an instance that commits the account to a contract period of 1, 12 or 24
months and has no task. A Go means the Product Owner accepts that one desired configuration
can express both, that the cost is shown and confirmed before any request, and that a retry
cannot create a second server, so that later milestones can delete, back up and restore the
servers this one creates.

## Deliverable

- The CLI defines a named desired configuration, checks it against the discovered capabilities
  and options of the provider, and saves it as valid or reports what is unsupported.
- The CLI provisions a server from a valid configuration at either provider: it shows what
  will be created and its cost consequence, asks for confirmation, follows the operation to its
  end, records the server as managed by this client, and reports the state left at the provider
  when a request fails.
- A decision record for the desired configuration, the cost confirmation, the protection
  against duplicate creation and the managed-server marker.
- The design artifacts revised for creation: domain model, dictionary, system sequence
  diagrams, operation contracts, design class diagram and the entity relationship diagram of the
  desired configuration and the managed-server record.
- Mock providers extended with the create endpoints, and the contract suite extended with the
  provisioning behaviours for the fake, Proxmox VE and Contabo.
- Opt-in live tests and a written result of a live run that creates a server in the Docker
  Proxmox VE of the integration tests. No Contabo instance is created live (cost).

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | All | Any missing or not Go |
| 2 | The same provisioning contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | All three | Any fails or is skipped |
| 3 | The acceptance criteria of US-001.03 and US-001.04 are each shown by an automated test through the CLI for both providers | All | Any not shown |
| 4 | A test shows that no create request is sent to a provider before the confirmation is given, and that the confirmation states the provider, the target, the size, the image and, for Contabo, the contract period | Passes | Fails |
| 5 | A test shows that repeating a provisioning request after a timeout or a lost answer does not create a second server | Passes | Fails |
| 6 | A test shows that the only write requests the adapters can send are the four power actions and the create requests; no delete, cancel, reinstall, rescue, snapshot or resize request exists | Passes | Any other write request found |
| 7 | A test shows that no credential value appears in a desired configuration, a managed-server record, an operation record or an error text | Passes | Fails |
| 8 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 9 | A live run that provisions a server in the Docker Proxmox VE, records it as managed and follows the operation to its end is recorded and passes | Passes | Fails or not run |
| 10 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-004] accepted with a `Go` | Operation tracking, the confirmation rules, the power port and the contract suite this slice extends |
| ADR-0002, ADR-0005 and ADR-0006 accepted | Capability model, provider credentials, operations and confirmation |
| The Docker Proxmox VE | Only for the live run (task 13): `tests/integration/docker-compose.proxmox.yml`, which needs `/dev/kvm` |
| A way to remove the test server | The product has no delete (UC-012 is a later milestone), so the live test removes only what it created, through a test-only helper that is not part of the product |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: the agreed use cases | [BC-001] Objectives |
| Objective 2: provider-specific behaviour explicit through capability checks | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| US-001.03 Define desired server configuration | [US-001] |
| US-001.04 Provision a server | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-11-30 — six weeks from 2026-10-19, an assumption to be confirmed by S01. The Business
Case states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Decide the desired configuration, the cost confirmation and duplicate protection | Record in an ADR how a desired configuration is modelled (a provider-neutral part and a provider-specific part, open points of UC-003), what the cost confirmation must show, how a retry is kept from creating a second server (record the intent before the request, look for the name first), how a created server is marked as managed (local record, Contabo tag as an option), and which create requests join the write allow-list. | No | ADR |
| 2 | Revise the design artifacts for creation | Add the desired configuration and the managed server to the domain model and dictionary, system sequence diagrams for UC-003 and UC-004, operation contracts, design class diagram revision and the desired configuration and managed-server record in the entity relationship diagram. | No | DM, DICT, SSD, OC, DCD, ERD |
| 3 | Domain and ports for configurations and creation | The desired-configuration value objects and validation, the provisioning capability, and a narrow `ServerProvisionPort` beside the power port, with fakes and unit tests that need no network. | No | DCD |
| 4 | Proxmox VE creation | Create a container or a virtual machine on a node with the next free identifier from the cluster, return the task and follow it to its exit status; the permission needed (`VM.Allocate`) is documented. | No | |
| 5 | Contabo creation | Create an instance with product, image, region and the contract period, report the instance status until it is running or the time limit passes, and show the period and the cost consequence before the request; a status that is not final is reported as unknown, not as success. | No | |
| 6 | Mocks and the provisioning contract suite | Extend the in-process mocks with the create endpoints, a failing create and a recorder whose allow-list is the four power writes and the create requests; run one provisioning contract suite for the fake, Proxmox VE and Contabo. | No | ADR-0001 |
| 7 | Desired-configuration and managed-server records | The local store of named desired configurations and of managed servers (one JSON Lines file per client, no secret), including the intent record used against duplicate creation. | No | ERD |
| 8 | Use cases and CLI commands | `DefineDesiredConfiguration` and `ProvisionServer` with the cost confirmation, and the commands `server define` and `server provision` with `--yes`, `--no-wait`, `--timeout`, a clear message for an unsupported choice, and the exit codes of the existing commands. | Yes | UC-003, UC-004 |
| 9 | End-to-end tests for both providers | The acceptance criteria of US-001.03 and US-001.04 through the CLI against the mocks, the confirmation test, the duplicate-creation test, the write-allow-list test and the no-secret test for the new records. | No | US-001 |
| 10 | Opt-in live tests and the wiki page | Integration tests that create a server only in the Docker Proxmox VE named by an environment variable and only after an explicit opt-in variable, with a test-only clean-up of what they created; a wiki page in bash and PowerShell. | No | |
| 11 | Update the verification note | Mark which creation statements of Proxmox VE (P5, P6, P13) and Contabo (C5, C6) the mocks and the live run confirm or contradict. | No | |
| 12 | Review the artifacts and the code | Review records for the decision record, the revised design and the source code against the Python code checklist, and update the traceability matrix. | No | |
| 13 | Live run in the Docker Proxmox VE | Run the opt-in live tests against the Docker Proxmox VE and record the result; no Contabo instance is created. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-004]: ./mil-004-power-control.md
[2034b4b]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/2034b4bbd73cdebb4b9dce6dd98afd83095a798c
[dad18d0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/dad18d0180d785602c76da8377c9aa9f915a825e
