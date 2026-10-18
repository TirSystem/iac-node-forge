# Go/No-Go check of MIL-004

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-066 |
| CrossReference | [MIL-004] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-004]
- Checklist used: none; the nine Go/No-Go criteria of MIL-004
- Scope: gate decision after the live run
- Language and domain: en / it (the artifact's Metadata rows)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI wrote most of what it checks and ran the live test. The plan was accepted by S01 on 2026-10-15.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | The decision record and the revised design artifacts have `Go` review records | Pass | ADR-0006: RC-055. Domain model, dictionary, SSD, OC, DCD, ERD: RC-056 to RC-063; DCD-001 revision 5: RC-065. |
| 2 | The same power contract tests pass for the fake, the Proxmox VE adapter and the Contabo adapter | Pass | One power contract suite over the three (iac-node-forge-py PR 13); nothing skipped; CI runs 1982 and 1983 on `main` at `68309a1` are green. |
| 3 | The acceptance criteria of US-001.05 and US-001.07 are each shown by an automated test through the CLI for both providers | Pass | `tests/e2e/test_power_through_cli.py` with the story ids in the docstrings (PR 14). |
| 4 | No request before the confirmation, and the extra confirmation for an unmanaged server | Pass | `test_an_unmanaged_server_needs_the_extra_confirmation_first` and the confirmation tests of `ControlServerPower`. |
| 5 | The only write requests the adapters can send are the four power actions | Pass | `test_the_only_writes_received_are_the_four_power_requests` and `test_only_get_the_four_power_posts_and_the_token_post_are_sent`; the mocks answer 405 to anything else. |
| 6 | No credential value in an operation record, the configuration file or an error text | Pass | `test_no_credential_value_appears_in_a_record_a_file_or_an_error`, `test_no_credential_is_written_to_the_configuration_file`, `test_no_credential_appears_in_an_error_text`, and the leak check inside the live tests. |
| 7 | The unit, contract and end-to-end tests pass in Gitea CI on Python 3.13 | Pass | `ci.yml` sets `PYTHON_VERSION` 3.13; runs 1982 and 1983 on `main` at `68309a1`: success. |
| 8 | A live run of start, shutdown and restart against a disposable server on at least one provider is recorded and passes | Pass | Proxmox VE, 2026-10-18: `pytest -m integration -k "power and proxmox" -v`, 2 passed in 583.72 s, against a disposable Alpine container in the Docker Proxmox VE; recorded in `docs/provider-api-verification.md`. The first attempt on 2026-10-16 (a VM without a guest OS) did not pass and led to the restore fix (PR 16). Not covered: a virtual machine with a guest OS, any Contabo power action. |
| 9 | The source code has a `Go` review against the Python code checklist | Pass | RC-064 (QC-PY-001), Go; one optional criterion (13) open. |

## Overall Verdict

Go — all nine criteria pass. This is the stand-in's decision in autonomous mode and is open to challenge by S01 and S02. Criterion 8 is met by one provider and by a container, not a virtual machine; the Contabo power path has been shown only against the mock.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Independent confirmation by S02 of the review records of MIL-004 (RC-053 to RC-066) | S02 | 2026-11-27 (MIL-004 decision date) |
| Run the power tests against a Contabo instance S01 can afford to turn off, and against a virtual machine with a guest OS | S01 | before provisioning or deletion is planned |
| Pin or lock the Python dependencies (RC-064) | S01 | with the next milestone |

---

[MIL-004]: ../../milestones/mil-004-power-control.md
