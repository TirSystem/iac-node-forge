# File backup and restore

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-007 |
| CrossReference | [BC-001], [US-001], [MIL-006] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Accepted after RC-093 (autonomous mode, stand-in) | pending |

---

## Purpose

Decide whether the product can reach the inside of a server, which it has so far treated only through
the provider's interface. The slice adds the backup of files from a server to the local PC (UC-016) and
their restore from the local PC to a server (UC-017) through the command-line interface (CLI). It is
provider-independent: it talks to the server itself over SSH, with the user's own SSH identity, agent and
`known_hosts` (ADR-0004), so the same code serves a Proxmox VE guest and a Contabo instance. A Go means the
Product Owner accepts that the product never stores a private key or a server password, that a copy is
verified complete before it is reported as done, that a restore says what it would overwrite before it
writes a byte, and that a host key it does not know stops the transfer.

## Deliverable

- The CLI backs up chosen files or folders from a server to a destination on the local PC: it checks that
  the destination has room, copies, verifies the copy against the server and reports what was copied;
  nothing on the server is changed.
- The CLI restores chosen files or folders from the local PC to a server: it lists what would be
  overwritten and asks for confirmation (with the extra confirmation for a server this client does not
  manage), copies, verifies and reports the result.
- A decision record for the way the product connects (the transfer method, the connection facts that are
  kept, the host key rules, how a copy is verified and how a restore is confirmed).
- The design artifacts revised for reaching a server: domain model, dictionary, system sequence diagrams,
  operation contracts, design class diagram and the entity relationship diagram of the connection facts.
- A transfer contract suite that runs against an in-process fake and, opt-in, against a real OpenSSH server
  in a throw-away container.
- Opt-in integration tests, a wiki page, and a written result of a live round trip (backup, change, restore,
  verify) against a throw-away SSH server.

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | All | Any missing or not Go |
| 2 | The same transfer contract tests pass for the in-process fake and for the OpenSSH adapter against a real SSH server, and the fake run is part of CI | Both | Any fails or is skipped |
| 3 | The acceptance criteria of US-001.09 and US-001.10 are each shown by an automated test through the CLI | All | Any not shown |
| 4 | A test shows that a backup changes nothing on the server and that a destination without enough room is refused with the reason before anything is copied | Passes | Fails |
| 5 | A test shows that a restore writes nothing before the confirmation, that it lists what would be overwritten, and that a server this client does not manage needs the extra confirmation | Passes | Fails |
| 6 | A test shows that a copy that differs from its source (one changed byte) is detected and reported as failed, not as done | Passes | Fails |
| 7 | A test shows that an unknown host key stops the transfer until it is explicitly accepted, and that a changed host key stops it and is never accepted automatically | Passes | Fails |
| 8 | A test shows that no password, passphrase, key or token appears in a record, a command line, the configuration file or an error text | Passes | Fails |
| 9 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | Fail |
| 10 | A live round trip against a throw-away SSH server (backup, change of the data, restore, verification of equality) is recorded and passes | Passes | Fails or not run |
| 11 | The source code has a `Go` review against the Python code checklist | Go | Not Go |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-006] accepted with a `Go` | The confirmation rules, the managed-server record and the operation record that the restore reuses |
| ADR-0004 and ADR-0006 accepted | Server access credentials and the confirmation rules |
| OpenSSH client tools on the machine that runs the CLI | The transfer method of the decision record; the live run also needs Docker for a throw-away SSH server (no `/dev/kvm` needed) |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: the agreed use cases | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| Objective 4: no secrets in configuration | [BC-001] Objectives |
| US-001.09 Back up server files to the local PC | [US-001] |
| US-001.10 Restore files from the local PC to the server | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-12-11 — about seven weeks from 2026-10-19, an assumption to be confirmed by S01. The Business Case
states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Decide the transfer method, the connection facts and the verification | Record in an ADR how the product connects (the system's OpenSSH tools started as processes, or an SSH library), which non-secret connection facts are kept per server (host, port, user, identity hint), how the host key is handled, how a copy is verified (a hash of every file compared on both sides), how room at the destination is checked, how a restore previews and confirms, and what the Windows and Linux differences are. | No | ADR |
| 2 | Revise the design artifacts for reaching a server | Add the server access, the transfer and its report to the domain model and dictionary, the system sequence diagrams and operation contracts for UC-016 and UC-017, the design class diagram revision and the connection facts in the entity relationship diagram. | No | DM, DICT, SSD, OC, DCD, ERD |
| 3 | Domain and ports for transfers | The server access and path value objects, the manifest and the transfer report, and the narrow ports for the remote side and the local files, with an in-process fake and unit tests that need no network. | No | DCD |
| 4 | OpenSSH adapter | Start the system's `ssh` (and the archive or copy tool of the decision record) as a process: list and hash remote files, stream a copy in either direction, honour the agent, the key files and `known_hosts`, stop on an unknown or changed host key, never put a secret on a command line. | No | ADR-0004 |
| 5 | Transfer contract suite | One suite that runs the same behaviours (copy, hash comparison, a changed byte, missing room, a path that does not exist, a host key that is unknown or changed) against the in-process fake and, opt-in, against a real OpenSSH server in a throw-away container. | No | ADR-0001 |
| 6 | Connection records | Keep the non-secret connection facts per server in the local JSON Lines file, with no secret, and read the server address from the provider when it is not recorded. | No | ERD |
| 7 | Use cases and CLI commands | `BackUpFiles` and `RestoreFiles` with the room check, the overwrite preview and the confirmation rules, and the commands `server backup` and `server restore` with `--yes`, `--confirm-unmanaged`, `--accept-host-key` and the exit codes of the existing commands. | Yes | UC-016, UC-017 |
| 8 | End-to-end tests | The acceptance criteria of US-001.09 and US-001.10 through the CLI against the in-process fake, the unchanged-server test, the room test, the overwrite and confirmation tests, the changed-byte test, the host key tests and the no-secret test. | No | US-001 |
| 9 | Opt-in integration tests and the wiki page | Integration tests that run the contract suite and a round trip against a throw-away OpenSSH server in a container, started by a compose file and used with a generated key pair that is deleted afterwards; a wiki page in bash and PowerShell. | No | |
| 10 | Update the documentation of provider and server facts | Record what the live run showed about the OpenSSH behaviour on the host (agent, `known_hosts`, host key prompts, archive tools) and what remains unverified (Windows agent, password-only servers). | No | |
| 11 | Review the artifacts and the code | Review records for the decision record, the revised design and the source code against the Python code checklist, and update the traceability matrix. | No | |
| 12 | Live round trip against a throw-away SSH server | Run the opt-in tests against the container, back up a tree, change it, restore it, verify equality, and record the result; no real server is touched. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-006]: ./mil-006-delete-or-cancel.md
