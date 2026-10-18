# Delete or cancel a server

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-006 |
| CrossReference | [BC-001], [US-001], [MIL-005] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Accepted after RC-081 (autonomous mode, stand-in) | pending |

---

## Purpose

Decide whether the capability model holds for the first action that cannot be undone. The slice
adds the removal of a server (UC-012), with the operation tracking of MIL-004, for Proxmox VE
and Contabo through the command-line interface (CLI). The two providers mean different things
by removal: Proxmox VE destroys the virtual machine or container at once and releases its disks,
and Contabo only records a request to cancel, with a cancel date, while the contract runs on
until then. A Go means the Product Owner accepts that one interface states the consequence of
each before anything is sent, that a removal is protected against accident, and that the
lifecycle (define, create, control, remove) is complete enough for the milestones that back up
and restore servers.

## Deliverable

- The CLI removes a server at either provider: it states whether the server is destroyed now or
  cancelled with an effective date, requires the identifier to be typed and, for a server this
  client does not manage, one more confirmation, follows the operation to its end, and records the
  consequence with the operation.
- A decision record for the removal kinds, the protection against accidental removal and the
  record kept after a removal.
- The design artifacts revised for removal: domain model, dictionary, system sequence diagram,
  operation contracts, design class diagram and the entity relationship diagram of the removal
  record.
- Mock providers extended with the delete and cancel endpoints, and the contract suite extended with
  the removal behaviours for the fake, Proxmox VE and Contabo.
- The live provisioning test cleans up with the product's own removal, so the test-only delete
  helper of MIL-005 is gone.
- Opt-in live tests, and a written result of a live run that removes a container the product
  created in the Docker Proxmox VE. No Contabo instance is cancelled live (cost and contract).

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | All | Any missing or not Go |
| 2 | The same removal contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | All three | Any fails or is skipped |
| 3 | The acceptance criteria of US-001.08 are each shown by an automated test through the CLI for both providers | All | Any not shown |
| 4 | A test shows that no removal request is sent before the identifier is typed, that a server this client does not manage needs one more confirmation, and that the consequence is stated first | Passes | Fails |
| 5 | A test shows that a running Proxmox VE server is refused and nothing is sent, and that the only write requests the adapters can send are the four power actions, the create requests and the two removals (Proxmox VE delete, Contabo cancel); no snapshot, reinstall, rescue or resize request exists | Passes | Any other write request found |
| 6 | A test shows that the consequence is recorded with the operation and that the managed-server record is ended after a removal | Passes | Fails |
| 7 | A test shows that no credential value appears in a removal record, the configuration file or an error text | Passes | Fails |
| 8 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 9 | A live run that removes a container the product created in the Docker Proxmox VE, with no test-only delete helper left, is recorded and passes | Passes | Fails or not run |
| 10 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-005] accepted with a `Go` | The creation that the removal undoes, the managed-server record, the operation tracking and the confirmation rules |
| ADR-0002, ADR-0006 and ADR-0007 accepted | Capability model, operations and confirmation, and the write allow-list |
| The Docker Proxmox VE | Only for the live run (task 13): `tests/integration/docker-compose.proxmox.yml`, which needs `/dev/kvm` |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: the agreed use cases | [BC-001] Objectives |
| Objective 2: provider-specific behaviour explicit through capability checks | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| US-001.08 Delete or cancel a server | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-11-27 — about five weeks from 2026-10-19, an assumption to be confirmed by S01. The Business
Case states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Decide the removal kinds, the protection and the record | Record in an ADR how removal is modelled (destroy now at Proxmox VE, cancel with an effective date at Contabo), what the consequence text must say, which protection applies (the identifier is always typed, one more confirmation for an unmanaged server, a running Proxmox VE server is refused and never stopped for the user), what the cancel date rule leaves open, and what is kept after a removal. | No | ADR |
| 2 | Revise the design artifacts for removal | Add the removal and its consequence to the domain model and dictionary, the system sequence diagram and operation contracts for UC-012, the design class diagram revision and the removal record in the entity relationship diagram. | No | DM, DICT, SSD, OC, DCD, ERD |
| 3 | Domain and ports for removal | The removal kinds, the capability `remove_server`, the action value `remove` and a narrow `ServerRemovalPort` beside the power and provision ports, with fakes and unit tests that need no network. | No | DCD |
| 4 | Proxmox VE removal | Delete a container or a virtual machine with `purge` and `destroy-unreferenced-disks`, refuse a running one before any request, return the task and follow it to its exit status; the permission needed (`VM.Allocate`) is documented. | No | |
| 5 | Contabo cancellation | Request the cancellation of an instance, read back the status and the cancel date the provider reports, and state that the contract continues until then; a status that is not final is reported as unknown, not as success. | No | |
| 6 | Mocks and the removal contract suite | Extend the in-process mocks with the delete and cancel endpoints, a failing removal and a recorder whose allow-list is the four power writes, the create requests and the two removals; run one removal contract suite for the fake, Proxmox VE and Contabo. | No | ADR-0001 |
| 7 | Removal record | Keep the consequence with the operation, end the managed-server record after a removal, and persist both without any secret. | No | ERD |
| 8 | Use case and CLI command | `RemoveServer` with the consequence text, the typed identifier and the extra confirmation, and the command `server remove` with `--yes`, `--confirm-unmanaged`, `--no-wait` and `--timeout`, a clear message for an unsupported or refused removal, and the exit codes of the existing commands. | Yes | UC-012 |
| 9 | End-to-end tests for both providers | The acceptance criteria of US-001.08 through the CLI against the mocks, the confirmation test, the running-server test, the write-allow-list test and the no-secret test for the removal record. | No | US-001 |
| 10 | Opt-in live test and the wiki page | Make the live provisioning test remove its container with the product's own removal and drop the test-only delete helper; update the wiki page in bash and PowerShell. | No | |
| 11 | Update the verification note | Mark which removal statements of Proxmox VE (P10, P13) and Contabo (C14) the mocks and the live run confirm or contradict, and what the cancel date rule turned out to be if it can be read. | No | |
| 12 | Review the artifacts and the code | Review records for the decision record, the revised design and the source code against the Python code checklist, and update the traceability matrix. | No | |
| 13 | Live run in the Docker Proxmox VE | Run the opt-in live test against the Docker Proxmox VE and record the result; no Contabo instance is cancelled. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-005]: ./mil-005-provisioning.md
