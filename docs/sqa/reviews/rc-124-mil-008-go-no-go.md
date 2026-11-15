# Go/No-Go check of MIL-008

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-124 |
| CrossReference | [MIL-008] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-11-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-008]
- Checklist used: none; the ten Go/No-Go criteria of MIL-008
- Scope: gate decision after the live run
- Language and domain: en / it (the artifact's Metadata rows)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI wrote most of what it checks and ran the live test. The plan was accepted by S01 on 2026-10-25. The code pull requests 27, 28 and 29 (iac-node-forge-py) and 153 were merged by a person.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | The provider facts, the decision record and the revised design artifacts have `Go` review records | Pass | Provider facts (B1 to B27 in `docs/provider-api-verification.md`) and ADR-0010: RC-111. Domain model RC-112, dictionary RC-113, SSD-011 and SSD-012 RC-114 and RC-115, OC-009 and OC-010 RC-116 and RC-117, DCD-001 revision 12 RC-118 and revision 13 RC-122, ERD-001 RC-119. Plan: RC-109, RC-110. |
| 2 | The same backup and restore contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | Pass | `tests/contract/test_backup_contract.py` runs for the fake, the Proxmox VE adapter against its mock and the Contabo adapter against its mock; `test_proxmox_backup.py` and `test_contabo_backup.py` hold the adapter cases. All run in the default suite and none is skipped. |
| 3 | The acceptance criteria of US-001.11 and US-001.12 are each shown by an automated test through the CLI for both providers, including a provider or server that cannot do it shown as unsupported | Pass | `tests/e2e/test_full_backup_through_cli.py` (story ids in the docstrings), among them `test_a_provider_that_does_not_support_it_is_shown_as_unsupported`, `test_a_backup_is_followed_to_completion_and_told_where_it_is_kept`, `test_a_completed_restore_reports_and_records_the_state_of_the_server`. |
| 4 | No restore request is sent before the identifier is typed, a server this client does not manage needs one more confirmation, and the consequence is stated first | Pass | `test_nothing_is_sent_before_the_plain_confirmation`, `test_the_restore_states_what_it_replaces_and_needs_the_typed_identifier`, `test_an_unmanaged_server_needs_the_extra_confirmation`, `test_a_name_or_a_prefix_is_not_the_identifier`, `test_proxmox_states_that_the_guest_is_overwritten`, `test_contabo_lists_the_newer_snapshots_the_rollback_deletes`. |
| 5 | The only write requests the adapters can send are the four power actions, the creations, the two removals, and the backup and restore requests | Pass | `tests/contract/test_mock_write_allow_list.py`: `test_proxmox_mock_refuses_and_records_every_write_outside_the_allow_list`, the same for Contabo, `test_proxmox_mock_allow_list_is_exactly_the_documented_writes`, and the e2e `test_only_the_backup_and_the_restore_writes_reach_the_provider`. |
| 6 | The place of the backup is recorded with the operation, the consequence of a restore is recorded, and the state of the server after a restore is reported | Pass | `test_a_backup_is_followed_to_completion_and_told_where_it_is_kept`, `test_the_backup_is_listed_and_completing_again_records_no_second_one`, `test_a_completed_restore_reports_and_records_the_state_of_the_server`, `test_a_restore_that_fails_later_reports_the_state_left`, and `test_a_lost_answer_is_unknown_and_the_restore_request_is_not_repeated`. |
| 7 | No credential value appears in a backup record, an operation record, the configuration file or an error text | Pass | `test_no_credential_value_appears_in_a_record_a_file_or_an_error`. |
| 8 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | Workflow `CI` (`ci.yml`, Python 3.13) on `main` of iac-node-forge-py at `1e39fa2`, the last merge of MIL-008: success, 1982 passed and 49 deselected (the opt-in integration tests), run 3206. Run 3202 on the merge of PR 28 ended in the runner while fetching the checkout action (no test ran) and run 3206 on the next commit passed; the pull request runs of the merged branches (2781, 2782) passed. See the finding below on the two other workflows. |
| 9 | A live run in the Docker Proxmox VE that backs up a container, changes it, restores it and checks that the change is gone is recorded and passes | Pass | 2026-10-25: `pytest -m integration -k "provision or full_backup"`, 2 passed in 1 h 4 min, recorded in `docs/provider-api-verification.md` (B1 to B16 Live column and the live run subsection) and in the wiki guide `Full-Backup-Live-Test`. A restore over the running container was refused by Proxmox VE itself (HTTP 500), and the product refuses it first. Not covered live: a virtual machine, the backup of a running guest, what a restore does to the content of a disk, and anything at Contabo. |
| 10 | The source code has a `Go` review against the Python code checklist | Pass | RC-123 (QC-PY-001), Go; one optional criterion (13, dependency pinning) open. |

## Overall Verdict

Go — all ten criteria pass. This is the stand-in's decision in autonomous mode and is open to challenge by S01 and S02. The live evidence is one guest type (a container) at one provider; Contabo snapshot and rollback and their completion were run only against the mock, and a Contabo restore deletes newer snapshots and its completion cannot be observed (B20).

**Finding, not part of the criteria.** On the same `main` commit the two shared workflows `Validate` (run 3209) and `OpenGrep` (run 3207) of `TirSystem/git-workflows` fail. Both report code of MIL-007, not of MIL-008: `shfmt` wants `>/home/tester/.ssh/authorized_keys` without a space in `tests/integration/sshd/entrypoint.sh`, and OpenGrep reports `src/iac_node_forge/infrastructure/openssh/_process.py` lines 67 and 114 (`subprocess.run` and `Popen` without a static string; the arguments are a list built by `OpenSshCommands`, no shell is used) and line 108 (a file object opened without a matching close). The first two look like audit notes on intended use and the third needs a look. They were not checked as a criterion of this milestone; they need a decision (fix, or silence with a justification).

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Decide and fix the `Validate` and `OpenGrep` findings in iac-node-forge-py (shfmt in the sshd entrypoint; three OpenGrep findings in `openssh/_process.py`) | S01 | before MIL-009 code work, or as a task of MIL-009 |
| Independent confirmation by S02 of the review records of MIL-008 (RC-109 to RC-124) | S02 | 2026-12-18 (MIL-008 decision date) |
| Try the restore of a virtual machine and the backup of a running guest at Proxmox VE, and a Contabo snapshot and rollback with a throw-away server when the cost is accepted | S01 | when a milestone needs them |
| Update UC-018 and UC-019: their Notes still call some points open | S01 | with MIL-009 |
| Pin or lock the Python dependencies (RC-123, optional criterion 13) | S01 | with the next milestone |

---

[MIL-008]: ../../milestones/mil-008-whole-server-backup-and-restore.md
