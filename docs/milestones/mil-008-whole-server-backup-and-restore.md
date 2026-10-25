# Whole-server backup and restore

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-008 |
| CrossReference | [BC-001], [US-001], [MIL-007] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-25 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Accepted after RC-109 (autonomous mode, stand-in) | pending |

---

## Purpose

Decide whether the capability model holds for the last of the agreed core actions, the backup and restore
of a whole server (UC-018, UC-019), where the two providers differ most. Proxmox VE has a native backup
(`vzdump`) that writes an archive to a backup storage and a restore that reads it into a guest. Contabo has
no backup interface in the documentation, only snapshots, so a backup there is a snapshot kept at the
provider and a restore is a rollback that deletes every newer snapshot. A Go means the Product Owner accepts
that one interface states what each provider really does before anything is sent, reports a provider that
cannot do it as unsupported, and keeps the destructive restore behind the same confirmation as a removal.
Copying a backup to the local PC is not part of this slice: neither provider documents a way to do it.

## Deliverable

- The CLI backs up a whole server at either provider, follows the operation to its end and reports where
  the backup is kept; a provider or a server that cannot do it is reported as unsupported.
- The CLI lists the backups the product knows of for a server, and restores a server from one of them: it
  states what the restore will replace (a guest overwritten at Proxmox VE; the newer snapshots deleted at
  Contabo) and the cost, requires the identifier typed and, for a server this client does not manage, one more
  confirmation, follows the operation, and records the consequence and the state of the server afterwards.
- Verified provider facts for backup and restore, in the verification note, before any design depends on them.
- A decision record for the backup model, the capabilities, the commands, what a restore replaces and the
  protection against accidental restore.
- The design artifacts revised for backup and restore: domain model, dictionary, system sequence diagrams,
  operation contracts, design class diagram and the entity relationship diagram of the backup record.
- Mock providers extended with the backup and restore endpoints, and the contract suite extended with the
  backup and restore behaviours for the fake, Proxmox VE and Contabo.
- Opt-in live tests and a written result of a live run in the Docker Proxmox VE that backs up a container,
  changes it, restores it and checks that the change is gone. No Contabo snapshot is created or rolled back by
  a test (cost, and a rollback deletes newer snapshots).

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The provider facts, the decision record and the revised design artifacts have `Go` review records | All | Any missing or not Go |
| 2 | The same backup and restore contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | All three | Any fails or is skipped |
| 3 | The acceptance criteria of US-001.11 and US-001.12 are each shown by an automated test through the CLI for both providers, including a provider or server that cannot do it shown as unsupported | All | Any not shown |
| 4 | A test shows that no restore request is sent before the identifier is typed, that a server this client does not manage needs one more confirmation, and that the consequence is stated first (what is replaced; for Contabo, which newer snapshots are deleted) | Passes | Fails |
| 5 | A test shows that the only write requests the adapters can send are the four power actions, the creations, the two removals, and the backup and restore requests; no snapshot deletion, reinstall, rescue or resize request exists | Passes | Any other write request found |
| 6 | A test shows that the place of the backup is recorded with the operation, that the consequence of a restore is recorded, and that the state of the server after a restore is reported | Passes | Fails |
| 7 | A test shows that no credential value appears in a backup record, an operation record, the configuration file or an error text | Passes | Fails |
| 8 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 9 | A live run in the Docker Proxmox VE that backs up a container, changes it, restores it and checks that the change is gone is recorded and passes | Passes | Fails or not run |
| 10 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-007] accepted with a `Go` | The last slice before this one; its design is the model |
| [MIL-005] and [MIL-006] accepted | The operation tracking, the confirmation rules, the managed-server record and the removal protection that a restore reuses |
| ADR-0002, ADR-0006, ADR-0007 and ADR-0008 accepted | Capability model, operations and confirmation, the write allow-list and the protection of destructive actions |
| The Docker Proxmox VE with a backup storage | Task 1 reads the backup interface of a real Proxmox VE and task 13 runs the live round trip; `/dev/kvm` is needed |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: the agreed use cases | [BC-001] Objectives |
| Objective 2: provider-specific behaviour explicit through capability checks | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| US-001.11 Back up a whole server | [US-001] |
| US-001.12 Restore a whole server from a backup | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-12-18 — about eight weeks from 2026-10-26, an assumption to be confirmed by S01. The Business Case
states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Verify the backup and restore facts | Read the backup and restore interface of the Proxmox VE documentation and of the Docker Proxmox VE (the dump request and its options, the storage content type, the archive volume, the restore request and what it does to an existing guest, the permissions) and the Contabo snapshot interface; record each statement with its source and mark which the mocks and the live run later confirm or contradict. | No | Verification note |
| 2 | Decide the backup model, the capabilities and the commands | Record in an ADR what a backup is at each provider (an archive volume at Proxmox VE, a snapshot at Contabo), where it is kept and how it is found again, what a restore replaces, the capabilities, the command names (the file backup keeps `server backup`), the confirmation and protection rules, and what is left out (copy to the local PC, deleting a backup, retention). | No | ADR |
| 3 | Revise the design artifacts for backup and restore | Add the backup and its restore to the domain model and dictionary, the system sequence diagrams and operation contracts for UC-018 and UC-019, the design class diagram revision and the backup record in the entity relationship diagram. | No | DM, DICT, SSD, OC, DCD, ERD |
| 4 | Domain and ports for backup and restore | The backup value object and actions, the capabilities, and a narrow `ServerBackupPort` beside the power, provision and removal ports, with fakes and unit tests that need no network. | No | DCD |
| 5 | Proxmox VE backup and restore | Start a dump of a guest to a backup storage and follow the task, find the archive again, restore it into a guest with the stated replace behaviour and follow the task; the permissions needed are documented. | No | |
| 6 | Contabo snapshot backup and rollback | Create a snapshot as the backup, list snapshots, roll back to one, state which newer snapshots are deleted before the request, and report a status that is not final as unknown. | No | |
| 7 | Mocks and the backup contract suite | Extend the in-process mocks with the dump, the restore, the snapshot and rollback endpoints, failing requests and a recorder whose allow-list is the existing writes plus these; run one contract suite for the fake, Proxmox VE and Contabo. | No | ADR-0001 |
| 8 | Backup record | Keep where each backup is kept, with the operation that made it and the consequence of each restore, in the local JSON Lines file without any secret, and list them. | No | ERD |
| 9 | Use cases and CLI commands | `BackUpServer`, `ListBackups` and `RestoreServer` with the consequence text, the typed identifier and the extra confirmation, and their commands with `--yes`, `--confirm-unmanaged`, `--no-wait` and `--timeout`, a clear message for an unsupported provider or server, and the exit codes of the existing commands. | Yes | UC-018, UC-019 |
| 10 | End-to-end tests for both providers | The acceptance criteria of US-001.11 and US-001.12 through the CLI against the mocks, the unsupported case, the confirmation and consequence tests, the write-allow-list test and the no-secret test. | No | US-001 |
| 11 | Opt-in live tests and the wiki page | Integration tests that back up, change and restore a container in the Docker Proxmox VE and check the result, with a clean-up through the product; a wiki page in bash and PowerShell. | No | |
| 12 | Review the artifacts and the code | Review records for the verified facts, the decision record, the revised design and the source code against the Python code checklist, and update the traceability matrix. | No | |
| 13 | Live run in the Docker Proxmox VE | Run the opt-in live tests against the Docker Proxmox VE and record the result; no Contabo snapshot is created or rolled back. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-005]: ./mil-005-provisioning.md
[MIL-006]: ./mil-006-delete-or-cancel.md
[MIL-007]: ./mil-007-file-backup-and-restore.md
