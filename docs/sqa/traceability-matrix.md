# Traceability Matrix

## Metadata
| Key | Value |
| --- | --- |
| ID | TM-001 |
| CrossReference | [BC-001], [SA-001], [PP-001], [MIL-001], [UCD-001], [US-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | AI (named by S01) | Added MIL-002 and the review records RC-030 and RC-031 | [116d271] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | AI (named by S01) | Added the MIL-002 design artifacts DICT-001, DM-001, SSD-001 to SSD-003, OC-001, DCD-001 and ERD-001 | [1f23e1f] |

---

## Purpose

Tracks backward/forward links between artifact instances so that the Business Case's
cross-artifact traceability success criterion is measurable. A row is added or
updated whenever an artifact instance is created or reviewed.

## Traceability Table

| Artifact Instance | Type | Language | Domain | Upstream (Backward Link) | Downstream (Forward Link) | Last Reviewed (RC-ID) |
| --- | --- | --- | --- | --- | --- | --- |
| [BC-001] | BC | en | it | - | [SA-001], [PP-001], [UCD-001] | [RC-001] |
| [SA-001] | SA | en | it | [BC-001] | [BC-001], [MIL-001] | [RC-002] |
| [PP-001] | PP | en | it | [BC-001], [SA-001] | [MIL-001] | [RC-031] |
| [MIL-001] | MIL | en | it | [BC-001], [PP-001] | [US-001], [UC-001] to [UC-019] | [RC-029] |
| [MIL-002] | MIL | en | it | [BC-001], [US-001], [MIL-001] | - | [RC-030] |
| [ADR-0001] | ADR | - | - | [BC-001], [MIL-001] | - | [RC-004] |
| [ADR-0002] | ADR | - | - | [BC-001], [MIL-001], [ADR-0001] | [UC-002], [UC-004], [UC-008], [UC-009], [UC-012], [UC-014], [UC-015] | [RC-005] |
| [ADR-0003] | ADR | - | - | [BC-001], [MIL-001] | [UC-001], [ADR-0004] | [RC-006] |
| [ADR-0004] | ADR | - | - | [BC-001], [MIL-001], [ADR-0003] | [UC-005], [UC-016], [UC-017] | [RC-007] |
| [UCD-001] | UCD | en | it | [SA-001], [BC-001] | [UC-001] to [UC-019] | [RC-008] |
| [US-001] | US | en | it | [BC-001], [MIL-001] | [UC-001] to [UC-019] | [RC-009] |
| [DICT-001] | DICT | en | it | [BC-001], [SA-001] | [DM-001] | - |
| [DM-001] | DM | en | it | [UC-001], [UC-002], [UC-007], [UCD-001] | [SSD-001], [DCD-001] | - |
| [SSD-001] to [SSD-003] | SSD | en | it | [UC-001], [UC-002], [UC-007], [DM-001] | [OC-001], [DCD-001] | - |
| [OC-001] | OC | - | - | [SSD-001], [DM-001] | [DCD-001] | - |
| [DCD-001] | DCD | - | - | [DM-001], [OC-001], [SSD-001] to [SSD-003] | [ERD-001] | - |
| [ERD-001] | ERD | - | - | [DCD-001] | - | - |
| UC-001 to UC-019 | UC | en | it | [UCD-001], [US-001], [SA-001] | - | RC-010 to RC-028 (one per use case) |

---

## Coverage Notes

- Types with no instance yet: KPI, RA, BMC, BPMN, DM, SSD, OC, SD, DCD, ERD, DICT, GOV.
- `-` in Upstream means foundational; in Downstream, nothing is built on it yet; in Last Reviewed, no review record exists.
- Reviews RC-001 to RC-028 were done by the AI at S01's instruction and are not independent; S02 confirmation is open.

---

[ADR-0001]: ../adr/adr-0001-provider-test-strategy.md
[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[ADR-0003]: ../adr/adr-0003-credential-storage.md
[ADR-0004]: ../adr/adr-0004-server-access-credentials.md
[BC-001]: ../business-case.md
[MIL-001]: ../milestones/mil-001-use-case-baseline.md
[PP-001]: ../project-plan.md
[RC-001]: ./reviews/rc-001-bc-001.md
[RC-002]: ./reviews/rc-002-sa-001.md
[RC-003]: ./reviews/rc-003-pp-001.md
[RC-004]: ./reviews/rc-004-adr-0001.md
[RC-005]: ./reviews/rc-005-adr-0002.md
[RC-006]: ./reviews/rc-006-adr-0003.md
[RC-007]: ./reviews/rc-007-adr-0004.md
[RC-008]: ./reviews/rc-008-ucd-001.md
[RC-009]: ./reviews/rc-009-us-001.md
[SA-001]: ../stakeholder-analysis.md
[UC-001]: ../use-cases/uc-001/uc.md
[UC-002]: ../use-cases/uc-002/uc.md
[UC-004]: ../use-cases/uc-004/uc.md
[UC-005]: ../use-cases/uc-005/uc.md
[UC-008]: ../use-cases/uc-008/uc.md
[UC-009]: ../use-cases/uc-009/uc.md
[UC-012]: ../use-cases/uc-012/uc.md
[UC-014]: ../use-cases/uc-014/uc.md
[UC-015]: ../use-cases/uc-015/uc.md
[UC-016]: ../use-cases/uc-016/uc.md
[UC-017]: ../use-cases/uc-017/uc.md
[UC-019]: ../use-cases/uc-019/uc.md
[UCD-001]: ../use-case-diagram.md
[US-001]: ../user-stories.md
[RC-029]: ./reviews/rc-029-mil-001.md
[RC-030]: ./reviews/rc-030-mil-002.md
[RC-031]: ./reviews/rc-031-pp-001.md
[MIL-002]: ../milestones/mil-002-read-only-slice-proxmox-cli.md
[116d271]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/116d271e1cc736e1bf4ad433cd5c5afc597463a4
[DICT-001]: ../dictionary.md
[DM-001]: ../domain-model.md
[SSD-001]: ../use-cases/uc-001/ssd.md
[SSD-002]: ../use-cases/uc-002/ssd.md
[SSD-003]: ../use-cases/uc-007/ssd.md
[OC-001]: ../use-cases/uc-001/oc.md
[DCD-001]: ../dcd.md
[ERD-001]: ../erd.md
[1f23e1f]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/1f23e1fc3e0a468ef08a393aa5fc50c87c4148cf
