# Use Case Baseline

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-001 |
| CrossReference | [BC-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [cd7ca06] |

---

## Purpose

Decide whether the set of use cases for iac-node-forge is complete and
agreed enough to start designing and building a first working slice. A Go
means the Product Owner accepts the use case baseline and the provider facts
it rests on.

## Deliverable

- Use Case Diagram for the agreed actors and use cases.
- One use case document per agreed candidate (UC-01 to UC-15), at least in
  Brief format, in `docs/uc-NNN/`.
- A note of verified Proxmox VE and Contabo API behaviour for the points the
  use cases depend on.
- Decision records for the capability model, for credential storage and for the provider test strategy.

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The Use Case Diagram exists and its review record says `Go` | Yes | No |
| 2 | Every use case marked Must or Should has a use case document with primary actor, preconditions and postconditions | All | Any missing |
| 3 | Every provider-dependent statement in the use cases is marked verified or assumption | All marked | Any unmarked |
| 4 | The ADRs for the capability model, credential storage and provider test strategy are `Accepted` | All three | Any not |
| 5 | Each use case document is reviewed with a `Go` record | All | Any not |
| 6 | Business Case and Stakeholder Analysis are `Accepted` | Both | Either not |

## Dependencies

| Depends on | Reason |
| --- | --- |
| BC-001 accepted | Objectives and scope the use cases trace to |
| SA-001 accepted | Stakeholder IDs for ownership and review |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: agreed use cases | [BC-001] Objectives |
| Objective 2: explicit provider behaviour | [BC-001] Objectives |
| Objective 3: same capabilities in both clients | [BC-001] Objectives |
| Objective 4: no secrets in configuration | [BC-001] Objectives |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2026-10-28 — assumption; the Business Case states no deadline yet.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Create the Use Case Diagram | Draw actors (DevOps, Product Owner) and the agreed use cases UC-01 to UC-15 so scope is visible in one place. Tailscale stays out of scope. | No | UCD |
| 2 | Write Brief use cases for Must candidates | Write Brief use cases for UC-01, UC-02, UC-03, UC-04, UC-06, UC-07, UC-08 and UC-12 in `docs/uc-NNN/uc.md`, from the candidate list agreed with the Product Owner. | Yes | UC-01 to UC-04, UC-06 to UC-08, UC-12 |
| 3 | Write Brief use cases for Should, Could and Open candidates | Cover UC-05, UC-09, UC-10, UC-11, UC-13, UC-14 and UC-15 so priorities can be reviewed together. | Yes | UC-05, UC-09 to UC-11, UC-13 to UC-15 |
| 4 | Verify provider API behaviour | Check the Proxmox VE and Contabo documentation for authentication, task or status model, snapshots, delete or cancel semantics and cloud-init support, and mark each use case statement as verified or assumption. | No | |
| 5 | Decide the provider capability model | Record in an ADR how provider differences are expressed (capability checks versus provider variants), because UC-02 feeds UC-04, UC-08, UC-09, UC-12, UC-14 and UC-15. | No | ADR |
| 6 | Decide credential storage | Record in an ADR how secrets are prompted for and cached: Windows Credential Manager, Windows Hello gating, and the fallback on hosts without a keyring. | No | ADR |
| 7 | Decide the provider test strategy | Record in an ADR how providers are tested: unit tests with fakes, contract tests against a mock provider container in Gitea CI, integration tests against a Proxmox VE VM outside CI, read-only smoke tests against live Contabo, and no create, update or delete on live Contabo (cost). | No | ADR |
| 8 | Test the Gitea runner for the mock provider | Check whether the Gitea CI runner supports Docker, service containers or Docker-in-Docker, so ADR-0001 can fix how the mock provider runs in CI. If it does not, the in-process mock server is used. | No | ADR-0001 |
| 9 | Review each artifact | Create review records (`RC-*`) for every document of this phase and update the traceability matrix. | No | |

---

[BC-001]: ../business-case.md
[SA-001]: ../stakeholder-analysis.md
[cd7ca06]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/cd7ca06b28cdb5ab7298312602798e2b861bc908
