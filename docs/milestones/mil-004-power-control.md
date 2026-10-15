# Power control

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-004 |
| CrossReference | [BC-001], [US-001], [MIL-003] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [e23414a] |

---

## Purpose

Decide whether the capability model holds for the first action that changes state. The
slice adds start, graceful shutdown, hard stop and restart of a server (UC-008) and the
tracking of the operation they start (UC-006), for Proxmox VE and Contabo through the same
command-line interface (CLI). The two providers differ most here: Proxmox VE answers with a
task that can be followed, and Contabo has only the server's status. A Go means the
Product Owner accepts that the interface expresses both, and that its safeguards (explicit
confirmation, no destructive action reachable) are sufficient for later milestones that
create and remove servers.

## Deliverable

- The CLI starts, shuts down, stops and restarts a server at either provider, asks for
  confirmation before acting, follows the operation to its end and reports the resulting
  state; an unsupported action is reported as unsupported.
- A decision record for the power actions, operation tracking and confirmation rules.
- The design artifacts revised for a state-changing slice: domain model, dictionary,
  system sequence diagrams, operation contracts, design class diagram and the entity
  relationship diagram of the operation record.
- Mock providers extended with the four power endpoints and a task, and the contract suite
  extended with the power behaviours for the fake, Proxmox VE and Contabo.
- Opt-in live tests, and a written result of a live run against a disposable server named by
  the Product Owner.

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | All | Any missing or not Go |
| 2 | The same power contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | All three | Any fails or is skipped |
| 3 | The acceptance criteria of US-001.05 and US-001.07 are each shown by an automated test through the CLI for both providers | All | Any not shown |
| 4 | A test shows that no request is sent to a provider before the confirmation is given, and that an unmanaged server needs the extra confirmation | Passes | Fails |
| 5 | A test shows that the only write requests the adapters can send are the four power actions: no delete, cancel, reinstall, rescue, snapshot or create request exists | Passes | Any other write request found |
| 6 | A test shows that no credential value appears in an operation record, the configuration file or an error text | Passes | Fails |
| 7 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 8 | A live run of start, shutdown and restart against a disposable server on at least one provider is recorded and passes | Passes | Fails or not run |
| 9 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-003] accepted | Two adapters behind one port, the provider-neutral contract suite and the CLI this slice extends |
| ADR-0002 and ADR-0005 accepted | Capability model and the provider credentials |
| A disposable server | Only for the live run (task 13): a Proxmox VE VM or a Contabo instance that the Product Owner can afford to turn off |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: the agreed use cases | [BC-001] Objectives |
| Objective 2: provider-specific behaviour explicit through capability checks | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| US-001.05 Track long-running operations | [US-001] |
| US-001.07 Start, stop and restart a server | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-11-27 — six weeks from 2026-10-16, an assumption to be confirmed by S01. The Business
Case states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Decide power actions, operation tracking and confirmation | Record in an ADR how power actions are modelled in the common port, how an operation is followed (a Proxmox VE task, or polling the Contabo status until it matches or a time limit passes), what is recorded, which actions need confirmation, and what happens when the server is already in the requested state. | No | ADR |
| 2 | Revise the design artifacts for a state-changing slice | Add the operation concept to the domain model and dictionary, system sequence diagrams for UC-008 and UC-006, operation contracts for the four actions, design class diagram revision and the operation record in the entity relationship diagram. | No | DM, DICT, SSD, OC, DCD, ERD |
| 3 | Domain and ports for power actions and operations | The operation value objects and states, the power capabilities, and the port operations to start an action and to read an operation's state, with fakes and unit tests that need no network. | No | DCD |
| 4 | Proxmox VE power actions | Start, shutdown, stop and reboot of virtual machines and containers, returning the task and following it to its exit status; the write permission needed is documented. | No | |
| 5 | Contabo power actions | Start, shutdown, stop and restart of an instance, and following the status until it matches the target or a time limit passes; a status that is not final is reported as unknown, not as success. | No | |
| 6 | Mocks and the power contract suite | Extend the in-process mocks with the power endpoints, a task or a status change over time, failures and a recorder that allows only the four power writes; run one power contract suite for the fake, Proxmox VE and Contabo. | No | ADR-0001 |
| 7 | Use cases and operation record | `ControlServerPower` and `TrackOperation`, the confirmation rules, and the operation record persisted without any secret. | Yes | UC-008, UC-006 |
| 8 | CLI power commands | `server start`, `shutdown`, `stop` and `restart` with confirmation (`--yes` to skip), `--no-wait` and `--timeout`, a clear message for an unsupported action, and the exit codes of the existing commands. | Yes | UC-008, UC-006 |
| 9 | End-to-end tests for both providers | The acceptance criteria of US-001.05 and US-001.07 through the CLI against the mocks, the confirmation and write-allow-list tests, and the no-secret test for the operation record. | No | US-001 |
| 10 | Opt-in live tests and the wiki page | Integration tests that act only on a server named by an environment variable and only after an explicit opt-in variable; a wiki page in bash and PowerShell with the warning that the server will be turned off. | No | |
| 11 | Update the verification note | Mark which power-action statements of Proxmox VE (P7, P3, P4) and Contabo (C10) the mocks and the live run confirm or contradict. | No | |
| 12 | Review the artifacts and the code | Review records for the decision record, the revised design and the source code against the Python code checklist, and update the traceability matrix. | No | |
| 13 | Live run against a disposable server | Run the opt-in live tests against a disposable server named by S01 and record the result; no server is deleted, cancelled, reinstalled or created. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-003]: ./mil-003-contabo-read-only-adapter.md
[e23414a]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/e23414a185edb1d4a116688272436fcf931ca7c4
