# Go/No-Go check of MIL-006

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-092 |
| CrossReference | [MIL-006] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-006]
- Checklist used: none; the ten Go/No-Go criteria of MIL-006
- Scope: gate decision after the live run
- Language and domain: en / it (the artifact's Metadata rows)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI wrote most of what it checks and ran the live test. The plan was accepted by S01 on 2026-10-18.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | Pass | ADR-0008: RC-083. Domain model RC-084, dictionary RC-085, SSD-008 RC-086, OC-006 RC-087, DCD-001 revision 8 RC-088 and revision 9 RC-090, ERD-001 revision 5 RC-089. |
| 2 | The same removal contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | Pass | `tests/contract/test_removal_contract.py`, 19 tests over the three (57 cases), nothing skipped (iac-node-forge-py PR 21, merged with PR 22); CI on `main` is green (runs recorded below). |
| 3 | The acceptance criteria of US-001.08 are each shown by an automated test through the CLI for both providers | Pass | `tests/e2e/test_removal_through_cli.py`: 14 tests, 28 cases (both providers), the story id in each docstring (PR 22). |
| 4 | No removal request before the typed identifier, one more confirmation for an unmanaged server, and the consequence stated first | Pass | `test_the_consequence_is_stated_and_a_confirmation_is_required_before_sending`, `test_an_unmanaged_server_needs_the_extra_confirmation`, `test_the_identifier_is_typed_twice_for_an_unmanaged_server_at_a_terminal`, `test_a_name_or_a_prefix_is_not_the_identifier`; the live test also checked that a wrong identifier and a missing confirmation send nothing. |
| 5 | A running Proxmox VE server is refused with no request, and the only writes are the four power actions, the creations and the two removals | Pass | `test_a_server_that_cannot_be_removed_now_is_refused_without_a_request`, `test_only_the_removal_write_reaches_the_provider`, `test_mock_write_allow_list.py` (the mocks answer 405 to anything else) and the source-scan tests; the live test saw exactly one POST and one DELETE. |
| 6 | The consequence is recorded with the operation and the managed-server record is ended after a removal | Pass | `test_a_completed_removal_records_the_consequence_and_ends_the_managed_record`, `test_completing_a_removal_again_changes_nothing`, the store tests, and the live run (record ended, container no longer listed). |
| 7 | No credential value in a removal record, the configuration file or an error text | Pass | `test_no_credential_value_appears_in_a_record_a_file_or_an_error` for both providers, and the leak check inside the live test. |
| 8 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | `ci.yml` sets `PYTHON_VERSION` 3.13; runs 2317 and 2318 on `main` at `090f663` (the last merge of MIL-006): success. |
| 9 | A live run that removes a container the product created in the Docker Proxmox VE, with no test-only delete helper left, is recorded and passes | Pass | 2026-10-18: `pytest -m integration -k provision -v`, 1 passed in 1183.41 s, recorded in `docs/provider-api-verification.md`; the test-only helper `_TestOnlyCleanup` and every raw delete are gone from the tests. Not covered: a virtual machine, a running guest, the permission error, any Contabo statement. |
| 10 | The source code has a `Go` review against the Python code checklist | Pass | RC-091 (QC-PY-001), Go; one optional criterion (13) open. |

## Overall Verdict

Go — all ten criteria pass. This is the stand-in's decision in autonomous mode and is open to challenge by S01 and S02. Criterion 9 is met by one provider and by a container; the Contabo cancellation, the shape of its answer and the rule of the cancel date have been exercised only against the mock, and nobody has provoked a real timeout or the removal of a running guest.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Independent confirmation by S02 of the review records of MIL-006 (RC-081 to RC-092) | S02 | 2026-11-27 (MIL-006 decision date) |
| Verify the Contabo cancellation, the shape of its answer and the rule of the cancel date against an account S01 can afford to cancel an instance on, and run the removal of a virtual machine in the Docker Proxmox VE | S01 | before delete or backup is planned |
| Pin or lock the Python dependencies (RC-091) | S01 | with the next milestone |

---

[MIL-006]: ../../milestones/mil-006-delete-or-cancel.md
