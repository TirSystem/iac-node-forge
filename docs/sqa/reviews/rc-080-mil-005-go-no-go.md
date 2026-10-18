# Go/No-Go check of MIL-005

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-080 |
| CrossReference | [MIL-005] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-005]
- Checklist used: none; the ten Go/No-Go criteria of MIL-005
- Scope: gate decision after the live run
- Language and domain: en / it (the artifact's Metadata rows)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI wrote most of what it checks and ran the live test. The plan was accepted by S01 on 2026-10-18.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | Pass | ADR-0007: RC-069. Domain model RC-070, dictionary RC-071, SSD-006 and SSD-007 RC-072 and RC-073, OC-004 and OC-005 RC-074 and RC-075, DCD-001 revision 6 RC-076 and revision 7 RC-079, ERD-001 RC-077. |
| 2 | The same provisioning contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | Pass | `tests/contract/test_provision_contract.py`, 17 tests over the three (51 cases), nothing skipped (iac-node-forge-py PR 17); CI runs 2244 and 2245 on `main` at `29cca0c` are green. |
| 3 | The acceptance criteria of US-001.03 and US-001.04 are each shown by an automated test through the CLI for both providers | Pass | `tests/e2e/test_provisioning_through_cli.py`: 15 tests, 30 cases (both providers), the story id in each docstring (PR 18). |
| 4 | No create request before the confirmation, and the confirmation states the provider, target, size, image and, for Contabo, the period | Pass | `test_the_preview_shows_what_is_created_and_the_cost_and_sends_nothing` and `test_the_contract_period_is_part_of_what_is_confirmed`; the unit test of `ProvisionServer` checks that no intent and no request exist before the confirmation. |
| 5 | Repeating a provisioning request after a timeout or a lost answer does not create a second server | Pass | `test_a_repeat_after_a_time_limit_sends_no_second_create_request`, `test_a_repeat_after_a_lost_answer_sends_no_second_create_request` (exactly one create body at the mock), the unit test `test_a_request_whose_answer_is_lost_keeps_the_intent_pending`, and the adapter tests that map a timeout (both providers) and a 5xx (Contabo) to `UNKNOWN`. A real timeout was not provoked. |
| 6 | The only write requests the adapters can send are the four power actions and the create requests | Pass | `test_only_the_allowed_write_requests_reach_the_provider` (end to end), `test_mock_write_allow_list.py` (the mocks answer 405 to anything else), and the source-scan tests; the only delete is the test-only helper in the live test file. |
| 7 | No credential value in a desired configuration, a managed-server record, an operation record or an error text | Pass | `test_no_credential_value_appears_in_a_record_a_file_or_an_error` for both providers, the store tests, and the leak check inside the live test. |
| 8 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | `ci.yml` sets `PYTHON_VERSION` 3.13; runs 2240 and 2241 on `main` at `61fb4f6` and runs 2244 and 2245 at `29cca0c`: success. |
| 9 | A live run that provisions a server in the Docker Proxmox VE, records it as managed and follows the operation to its end is recorded and passes | Pass | 2026-10-18: `pytest -m integration -k provision -v`, 1 passed in 1042.83 s, a container with an Alpine template, recorded in `docs/provider-api-verification.md`. Not covered: a virtual machine, the permission error, a taken identifier, any Contabo statement. |
| 10 | The source code has a `Go` review against the Python code checklist | Pass | RC-078 (QC-PY-001), Go; two findings fixed by iac-node-forge-py PR 20; one optional criterion (13) open. |

## Overall Verdict

Go — all ten criteria pass. This is the stand-in's decision in autonomous mode and is open to challenge by S01 and S02. Criterion 9 is met by one provider and by a container; the Contabo creation, its product list path and its status sequence have been exercised only against the mock, and nobody has provoked a real timeout.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Independent confirmation by S02 of the review records of MIL-005 (RC-067 to RC-080) | S02 | 2026-11-30 (MIL-005 decision date) |
| Verify the Contabo creation, the product list path and the status sequence against a real account S01 can afford, and run the virtual machine creation in the Docker Proxmox VE | S01 | before delete or backup is planned |
| Pin or lock the Python dependencies (RC-078) | S01 | with the next milestone |

---

[MIL-005]: ../../milestones/mil-005-provisioning.md
