# Go/No-Go check of MIL-007

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-108 |
| CrossReference | [MIL-007] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-21 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-007]
- Checklist used: none; the eleven Go/No-Go criteria of MIL-007
- Scope: gate decision after the live run
- Language and domain: en / it (the artifact's Metadata rows)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI wrote most of what it checks and ran the live test. The plan was accepted by S01 on 2026-10-18.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | Pass | ADR-0009: RC-095, revision 2 RC-104. Domain model RC-096, dictionary RC-097, SSD-009 and SSD-010 RC-098 and RC-100, OC-007 and OC-008 RC-099 and RC-101, OC-008 revision 2 RC-105, DCD-001 revision 10 RC-102 and revision 11 RC-106, ERD-001 RC-103. |
| 2 | The same transfer contract tests pass for the in-process fake and for the OpenSSH adapter against a real SSH server, and the fake run is part of CI | Pass | `tests/contract/test_transfer_contract.py`: 25 fake cases in the default suite and CI (runs 2464 and 2465 on `main` at `cd2af77` are green), and 24 passed and 1 skipped against the real container with both Git-for-Windows and Windows-native OpenSSH (2026-10-19, before PR 24 was merged). The one skipped case, the room check, is fake-only; the real local disk check has its own unit tests. The real run was not repeated after the last fix, which touched the use cases and not the adapters. |
| 3 | The acceptance criteria of US-001.09 and US-001.10 are each shown by an automated test through the CLI | Pass | `tests/e2e/test_transfer_through_cli.py`, 12 tests with the story ids in the docstrings (PR 25, PR 26), and the live round trip through the real CLI. |
| 4 | A backup changes nothing on the server and a destination without enough room is refused first | Pass | `test_a_backup_is_copied_verified_and_changes_nothing_on_the_server`, `test_a_destination_without_room_is_refused_with_the_reason`, the contract test that compares the remote tree before and after, and step 4 of the live test. |
| 5 | A restore writes nothing before the confirmation, lists what it would overwrite, and needs the extra confirmation for a server this client does not manage | Pass | `test_a_restore_tells_what_is_overwritten_and_needs_a_confirmation_first`, `test_an_unmanaged_server_needs_the_extra_confirmation`, `test_a_name_or_a_prefix_is_not_the_identifier`, and step 6 of the live test (the remote manifest is unchanged without the confirmation). |
| 6 | A copy that differs from its source (one changed byte) is detected and reported as failed, not as done | Pass | `test_one_changed_byte_is_a_failure_and_never_reported_as_done` (backup and restore) and the contract test of a changed byte. The rule for a restore is: a missing or changed file fails it; a file already on the server is left in place and noted (ADR-0009 revision 2), `test_a_file_added_on_the_server_is_left_in_place_and_reported`. |
| 7 | An unknown host key stops the transfer until it is explicitly accepted, and a changed host key stops it and is never accepted | Pass | `test_an_unknown_host_key_stops_until_its_fingerprint_is_accepted`, `test_a_changed_host_key_stops_and_is_never_accepted`, the contract tests, and steps 3 and 7 of the live test. |
| 8 | No password, passphrase, key or token appears in a record, a command line, the configuration file or an error text | Pass | `test_no_secret_is_stored_or_shown`, the argv tests of `OpenSshCommands` (the only place that builds argv, no shell, no secret), and step 8 of the live test. |
| 9 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | `ci.yml` sets `PYTHON_VERSION` 3.13; runs 2464 and 2465 on `main` at `cd2af77` (the last merge of MIL-007): success. |
| 10 | A live round trip against a throw-away SSH server (backup, change of the data, restore, verification of equality) is recorded and passes | Pass | 2026-10-20: `IACNF_SSHD_TEST=1 pytest -m integration -k transfer_live`, 1 passed in 15.0 s against OpenSSH 9.9 with BusyBox 1.37 in a container, recorded in `docs/provider-api-verification.md` (T1 to T10). Not covered: a GNU userland server, password and passphrase prompts, the Windows agent service, Linux and macOS clients. |
| 11 | The source code has a `Go` review against the Python code checklist | Pass | RC-107 (QC-PY-001), Go; one optional criterion (13) open. |

## Overall Verdict

Go — all eleven criteria pass. This is the stand-in's decision in autonomous mode and is open to challenge by S01 and S02. The live evidence is one server type (BusyBox) and Windows clients; the transfer has not been tried against a server with GNU tools, with a password or passphrase prompt, or with the Windows ssh-agent, and it is the first slice that works inside a server.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Independent confirmation by S02 of the review records of MIL-007 (RC-093 to RC-108) | S02 | 2026-12-11 (MIL-007 decision date) |
| Try a backup and a restore against a real Linux server with GNU tools and against a server that asks for a password or passphrase, from Linux or macOS if available | S01 | before whole-server backup is planned |
| Update UC-016 and UC-017: their Notes still call the transfer method and the previous version of overwritten data open | S01 | with the next milestone |
| Pin or lock the Python dependencies (RC-107) | S01 | with the next milestone |

---

[MIL-007]: ../../milestones/mil-007-file-backup-and-restore.md
