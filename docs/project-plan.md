# Project Plan

## Metadata
| Key | Value |
| --- | --- |
| ID | PP-001 |
| CrossReference | [BC-001], [SA-001], [MIL-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [cd7ca06] |

---

## Purpose

Schedule the phases (gateways) of iac-node-forge from the agreed use cases to
working software. Only the first phase is planned in detail. The Business Case
states no duration or deadline yet, so the plan has no fixed end date.

## Planning Assumptions

- The plan starts on 2026-10-14. This date is an assumption to confirm.
- Phase length for MIL-001 is two weeks. This is an assumption to confirm.
- Each phase ends with a Go/No-Go decision by S01, after a review by S02
  ([SA-001]).
- Later phases are planned only after MIL-001 is accepted.

## Gateway Schedule

| Gateway | Document | Window | Decision date | Owner | Stories | Main deliverable | Milestone |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Use case baseline | [MIL-001] | 2026-10-14 to 2026-10-28 | 2026-10-28 | S01 | UC-01 to UC-15 (candidates) | Use Case Diagram, brief use cases, verified provider facts, ADRs | |

```plantuml
@startgantt
Project starts 2026-10-14
[MIL-001 Use case baseline] starts 2026-10-14 and ends 2026-10-28
[MIL-001 Go/No-Go] happens 2026-10-28
@endgantt
```

## Scope Coverage

| Business Case scope item | Gateway |
| --- | --- |
| Provider access and validation for Proxmox VE and Contabo | MIL-001 (use cases only); software not yet planned |
| Server lifecycle use cases | MIL-001 (use cases only); software not yet planned |
| Display of servers not managed by this client | MIL-001 (use case UC-07); software not yet planned |
| Python CLI and WinUI 3 application | Not yet planned |
| JSONL configuration file per client | Not yet planned |

## Dependencies

```
MIL-001 Use case baseline -> (later phases, not yet planned)
```

A No-Go on MIL-001 delays every later phase, because nothing under `src/` or
`tests/` may start before an accepted, reviewed milestone.

## Plan Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Provider API facts turn out different from the assumptions in the use case list | Use cases change after MIL-001 | MIL-001 includes a task that verifies provider behaviour against the documentation before acceptance |
| Only one reviewer (S02) is available | Review becomes a bottleneck | Keep MIL-001 small; review documents as they are produced |
| Gitea CI cannot run a Proxmox VE VM | Integration tests on Proxmox cannot gate merges | Test strategy ADR in MIL-001 sets CI to mock-based contract tests; the VM runs outside CI |
| No deadline or budget stated | Plan cannot be checked against a constraint | Ask S01 to state them before MIL-002 is planned |

## Open Issues

- Start date and phase length are assumptions (see Planning Assumptions).
- The Business Case has no duration, budget or deadline.
- Which provider comes first in the first working slice (Proxmox VE or
  Contabo) is not decided; it shapes the next phase.
- Which client comes first (CLI or WinUI 3) is not decided.
- Later phases (first slice on one provider, second provider, second client)
  are candidates only and have no `MIL-*` document yet.

---

[BC-001]: ./business-case.md
[SA-001]: ./stakeholder-analysis.md
[MIL-001]: ./milestones/mil-001-use-case-baseline.md
[cd7ca06]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/cd7ca06b28cdb5ab7298312602798e2b861bc908
