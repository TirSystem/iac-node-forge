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
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Added the backup and restore use cases UC-016 to UC-019 to the tasks | [31933c9] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Criterion 4 and the deliverable include ADR-0004; added task 9 | [b664ca3] |

---

## Purpose

Decide whether the set of use cases for iac-node-forge is complete and
agreed enough to start designing and building a first working slice. A Go
means the Product Owner accepts the use case baseline and the provider facts
it rests on.

## Deliverable

- Use Case Diagram for the agreed actors and use cases.
- One use case document per agreed candidate (UC-01 to UC-19), at least in
  Brief format, in `docs/use-cases/uc-NNN/`.
- A note of verified Proxmox VE and Contabo API behaviour for the points the
  use cases depend on.
- Decision records for the capability model, for credential storage, for the provider test strategy and for server access credentials.

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | The Use Case Diagram exists and its review record says `Go` | Yes | No |
| 2 | Every use case marked Must or Should has a use case document with primary actor, preconditions and postconditions | All | Any missing |
| 3 | Every provider-dependent statement in the use cases is marked verified or assumption | All marked | Any unmarked |
| 4 | The ADRs for the capability model, credential storage, provider test strategy and server access credentials are `Accepted` | All four | Any not |
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
| 1 | Create the Use Case Diagram | Draw actors (DevOps, Product Owner) and the agreed use cases UC-01 to UC-19 so scope is visible in one place. Tailscale stays out of scope. | No | UCD |
| 2 | Write Brief use cases for Must candidates | Write Brief use cases for UC-01, UC-02, UC-03, UC-04, UC-06, UC-07, UC-08, UC-12, UC-16, UC-17, UC-18 and UC-19 in `docs/use-cases/uc-NNN/uc.md`, from the candidate list agreed with the Product Owner. | Yes | UC-01 to UC-04, UC-06 to UC-08, UC-12, UC-16 to UC-19 |
| 3 | Write Brief use cases for Should, Could and Open candidates | Cover UC-05, UC-09, UC-10, UC-11, UC-13, UC-14 and UC-15 so priorities can be reviewed together. | Yes | UC-05, UC-09 to UC-11, UC-13 to UC-15 |
| 4 | Verify provider API behaviour | Check the Proxmox VE and Contabo documentation for authentication, task or status model, snapshots, delete or cancel semantics and cloud-init support, and mark each use case statement as verified or assumption. | No | |
| 5 | Decide the provider capability model | Record in an ADR how provider differences are expressed (capability checks versus provider variants), because UC-02 feeds UC-04, UC-08, UC-09, UC-12, UC-14 and UC-15. | No | ADR |
| 6 | Decide credential storage | Record in an ADR how secrets are prompted for and cached: Windows Credential Manager, Windows Hello gating, and the fallback on hosts without a keyring. | No | ADR |
| 7 | Decide the provider test strategy | Record in an ADR how providers are tested: unit tests with fakes, contract tests against a mock provider container in Gitea CI, integration tests against a Proxmox VE VM outside CI, read-only smoke tests against live Contabo, and no create, update or delete on live Contabo (cost). | No | ADR |
| 8 | Test the Gitea runner for the mock provider | Check whether the Gitea CI runner supports Docker, service containers or Docker-in-Docker, so ADR-0001 can fix how the mock provider runs in CI. If it does not, the in-process mock server is used. | No | ADR-0001 |
| 9 | Decide server access credentials | Record in an ADR how the product logs in to servers over SSH for file backup and restore: the user's agent, key files and known_hosts, and no stored private keys or passwords. | No | ADR-0004 |
| 10 | Review each artifact | Create review records (`RC-*`) for every document of this phase and update the traceability matrix. | No | |

---

[BC-001]: ../business-case.md
[SA-001]: ../stakeholder-analysis.md
[31933c9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/31933c95a83dd3e114cc067cd907ddddb750b1bb
[b664ca3]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/b664ca34d52e7c4fe1561279e213dd6ffbeca3d5
