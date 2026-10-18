# Traceability Matrix

## Metadata
| Key | Value |
| --- | --- |
| ID | TM-001 |
| CrossReference | [BC-001], [SA-001], [PP-001], [MIL-001], [UCD-001], [US-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Proposed | Jens Tirsvad Nielsen | AI as stand-in for S02 | Added RC-066, the Go/No-Go check of MIL-004 | [5f95f60] |
| 2026-10-18 | Proposed | Jens Tirsvad Nielsen | AI as stand-in for S02 | Added MIL-005, RC-067 and RC-068 | pending |

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
| [PP-001] | PP | en | it | [BC-001], [SA-001] | [MIL-001] | [RC-031], [RC-048], [RC-054], [RC-068] |
| [MIL-001] | MIL | en | it | [BC-001], [PP-001] | [US-001], [UC-001] to [UC-019] | [RC-029] |
| [MIL-002] | MIL | en | it | [BC-001], [US-001], [MIL-001] | - | [RC-030], [RC-043], [RC-045], [RC-046] |
| [MIL-003] | MIL | en | it | [BC-001], [US-001], [MIL-002] | - | [RC-047], [RC-051], [RC-052] |
| [MIL-004] | MIL | en | it | [BC-001], [US-001], [MIL-003] | - | [RC-053], [RC-064], [RC-066] |
| [MIL-005] | MIL | en | it | [BC-001], [US-001], [MIL-004] | - | [RC-067] |
| [ADR-0001] | ADR | - | - | [BC-001], [MIL-001] | - | [RC-004], [RC-044] |
| [ADR-0002] | ADR | - | - | [BC-001], [MIL-001], [ADR-0001] | [UC-002], [UC-004], [UC-008], [UC-009], [UC-012], [UC-014], [UC-015] | [RC-005] |
| [ADR-0003] | ADR | - | - | [BC-001], [MIL-001] | [UC-001], [ADR-0004] | [RC-006] |
| [ADR-0004] | ADR | - | - | [BC-001], [MIL-001], [ADR-0003] | [UC-005], [UC-016], [UC-017] | [RC-007] |
| [ADR-0005] | ADR | - | - | [BC-001], [MIL-003], [ADR-0002], [ADR-0003] | [UC-001] | [RC-049] |
| [UCD-001] | UCD | en | it | [SA-001], [BC-001] | [UC-001] to [UC-019] | [RC-008] |
| [US-001] | US | en | it | [BC-001], [MIL-001] | [UC-001] to [UC-019] | [RC-009] |
| [DICT-001] | DICT | en | it | [BC-001], [SA-001] | [DM-001] | [RC-033], [RC-057] |
| [DM-001] | DM | en | it | [UC-001], [UC-002], [UC-007], [UCD-001] | [SSD-001], [DCD-001] | [RC-032], [RC-056] |
| [SSD-001] to [SSD-003] | SSD | en | it | [UC-001], [UC-002], [UC-007], [DM-001] | [OC-001], [DCD-001] | [RC-034] to [RC-036], [RC-041] |
| [OC-001] | OC | - | - | [SSD-001], [DM-001] | [DCD-001] | [RC-037] |
| [OC-002], [OC-003] | OC | - | - | [SSD-004], [SSD-005], [DM-001] | [DCD-001] | [RC-060], [RC-061] |
| [SSD-004], [SSD-005] | SSD | en | it | [UC-008], [UC-006], [DM-001] | [OC-002], [OC-003], [DCD-001] | [RC-058], [RC-059] |
| [ADR-0006] | ADR | - | - | [BC-001], [MIL-004], [ADR-0002], [ADR-0005] | [UC-006], [UC-008] | [RC-055] |
| [DCD-001] | DCD | - | - | [DM-001], [OC-001], [SSD-001] to [SSD-003] | [ERD-001] | [RC-038], [RC-040], [RC-050], [RC-062], [RC-065] |
| [ERD-001] | ERD | - | - | [DCD-001] | - | [RC-039], [RC-042], [RC-063] |
| UC-001 to UC-019 | UC | en | it | [UCD-001], [US-001], [SA-001] | - | RC-010 to RC-028 (one per use case) |

---

## Coverage Notes

- Types with no instance yet: KPI, RA, BMC, BPMN, DM, SSD, OC, SD, DCD, ERD, DICT, GOV.
- `-` in Upstream means foundational; in Downstream, nothing is built on it yet; in Last Reviewed, no review record exists.
- Reviews RC-001 to RC-068 were done by the AI at S01's instruction and are not independent; S02 confirmation is open.

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
[DICT-001]: ../dictionary.md
[DM-001]: ../domain-model.md
[SSD-001]: ../use-cases/uc-001/ssd.md
[SSD-002]: ../use-cases/uc-002/ssd.md
[SSD-003]: ../use-cases/uc-007/ssd.md
[OC-001]: ../use-cases/uc-001/oc.md
[DCD-001]: ../dcd.md
[ERD-001]: ../erd.md
[RC-032]: ./reviews/rc-032-dm-001.md
[RC-033]: ./reviews/rc-033-dict-001.md
[RC-034]: ./reviews/rc-034-ssd-001.md
[RC-035]: ./reviews/rc-035-ssd-002.md
[RC-036]: ./reviews/rc-036-ssd-003.md
[RC-037]: ./reviews/rc-037-oc-001.md
[RC-038]: ./reviews/rc-038-dcd-001.md
[RC-039]: ./reviews/rc-039-erd-001.md
[RC-040]: ./reviews/rc-040-dcd-001-rev2.md
[RC-041]: ./reviews/rc-041-ssd-001-rev2.md
[RC-042]: ./reviews/rc-042-erd-001-rev2.md
[RC-043]: ./reviews/rc-043-mil-002-rev2.md
[RC-044]: ./reviews/rc-044-adr-0001-rev3.md
[RC-045]: ./reviews/rc-045-python-code-mil-002.md
[RC-046]: ./reviews/rc-046-mil-002-go-no-go.md
[MIL-003]: ../milestones/mil-003-contabo-read-only-adapter.md
[RC-047]: ./reviews/rc-047-mil-003.md
[RC-048]: ./reviews/rc-048-pp-001-rev.md
[ADR-0005]: ../adr/adr-0005-contabo-credentials-and-token.md
[RC-049]: ./reviews/rc-049-adr-0005.md
[RC-050]: ./reviews/rc-050-dcd-001-rev3.md
[RC-051]: ./reviews/rc-051-python-code-mil-003.md
[RC-052]: ./reviews/rc-052-mil-003-go-no-go.md
[MIL-004]: ../milestones/mil-004-power-control.md
[MIL-005]: ../milestones/mil-005-provisioning.md
[RC-053]: ./reviews/rc-053-mil-004.md
[RC-054]: ./reviews/rc-054-pp-001-rev.md
[ADR-0006]: ../adr/adr-0006-power-actions-and-operation-tracking.md
[SSD-004]: ../use-cases/uc-008/ssd.md
[SSD-005]: ../use-cases/uc-006/ssd.md
[OC-002]: ../use-cases/uc-008/oc.md
[OC-003]: ../use-cases/uc-006/oc.md
[RC-055]: ./reviews/rc-055-adr-0006.md
[RC-056]: ./reviews/rc-056-dm-001-rev2.md
[RC-057]: ./reviews/rc-057-dict-001-rev2.md
[RC-058]: ./reviews/rc-058-ssd-004.md
[RC-059]: ./reviews/rc-059-ssd-005.md
[RC-060]: ./reviews/rc-060-oc-002.md
[RC-061]: ./reviews/rc-061-oc-003.md
[RC-062]: ./reviews/rc-062-dcd-001-rev4.md
[RC-063]: ./reviews/rc-063-erd-001-rev3.md
[RC-064]: ./reviews/rc-064-python-code-mil-004.md
[RC-065]: ./reviews/rc-065-dcd-001-rev5.md
[RC-066]: ./reviews/rc-066-mil-004-go-no-go.md
[5f95f60]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/5f95f6082305886506f860cadcddaf28cf07af04
[RC-067]: ./reviews/rc-067-mil-005.md
[RC-068]: ./reviews/rc-068-pp-001-mil-005.md
