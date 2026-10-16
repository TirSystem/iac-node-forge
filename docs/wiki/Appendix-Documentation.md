**English**

# Appendix: project documentation

Every document of the project lives under `docs/` in the repository. The links below open the
current version on the `main` branch. Each document has an ID, a version history and a review
record in [`docs/sqa/reviews/`](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/sqa/reviews); the
[traceability matrix](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/sqa/traceability-matrix.md) shows which document traces to which.

## Business and planning

- [Business Case](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/business-case.md)
- [Stakeholder Analysis](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/stakeholder-analysis.md)
- [Project Plan](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/project-plan.md)
- [User Stories](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/user-stories.md)
- [Use Case Diagram](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-case-diagram.md)

## Milestones

- [Use Case Baseline](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/milestones/mil-001-use-case-baseline.md) (`MIL-001`)
- [Read-only slice: Proxmox VE with the Python CLI](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/milestones/mil-002-read-only-slice-proxmox-cli.md) (`MIL-002`)
- [Contabo read-only adapter](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/milestones/mil-003-contabo-read-only-adapter.md) (`MIL-003`)
- [Power control](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/milestones/mil-004-power-control.md) (`MIL-004`)

## Use cases

Each use case is a folder `docs/use-cases/uc-NNN/` with the use case (`uc.md`) and, where the
design needed them, the system sequence diagram (`ssd.md`) and the operation contracts (`oc.md`).

| Use case | Definition | SSD | Contracts |
| --- | --- | --- | --- |
| UC-001: Configure and validate provider access | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-001/uc.md) | [ssd](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-001/ssd.md) | [oc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-001/oc.md) |
| UC-002: Discover capabilities and server options | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-002/uc.md) | [ssd](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-002/ssd.md) | - |
| UC-003: Define desired server configuration | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-003/uc.md) | - | - |
| UC-004: Provision a server | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-004/uc.md) | - | - |
| UC-005: Bootstrap a server after provisioning | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-005/uc.md) | - | - |
| UC-006: Track long-running operations | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-006/uc.md) | [ssd](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-006/ssd.md) | [oc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-006/oc.md) |
| UC-007: List and inspect servers | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-007/uc.md) | [ssd](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-007/ssd.md) | - |
| UC-008: Start, stop and restart a server | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-008/uc.md) | [ssd](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-008/ssd.md) | [oc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-008/oc.md) |
| UC-009: Manage snapshots | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-009/uc.md) | - | - |
| UC-010: Detect drift | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-010/uc.md) | - | - |
| UC-011: Correct drift | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-011/uc.md) | - | - |
| UC-012: Delete or cancel a server | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-012/uc.md) | - | - |
| UC-013: Review operation history and recover failed operations | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-013/uc.md) | - | - |
| UC-014: Manage SSH keys and secrets | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-014/uc.md) | - | - |
| UC-015: Resize, reinstall or rescue a server | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-015/uc.md) | - | - |
| UC-016: Back up server files to the local PC | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-016/uc.md) | - | - |
| UC-017: Restore files from the local PC to the server | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-017/uc.md) | - | - |
| UC-018: Back up a whole server | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-018/uc.md) | - | - |
| UC-019: Restore a whole server from a backup | [uc](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/use-cases/uc-019/uc.md) | - | - |

## Design

- [Domain Model](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/domain-model.md)
- [Domain Dictionary (PO and IT terms)](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/dictionary.md)
- [Design Class Diagram](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/dcd.md)
- [Entity Relationship Diagram](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/erd.md)

## Decisions

- [Provider test strategy](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/adr/adr-0001-provider-test-strategy.md) (`ADR-0001`)
- [Provider capability model](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/adr/adr-0002-provider-capability-model.md) (`ADR-0002`)
- [Credential storage](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/adr/adr-0003-credential-storage.md) (`ADR-0003`)
- [Server access credentials](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/adr/adr-0004-server-access-credentials.md) (`ADR-0004`)
- [Contabo credentials and token handling](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/adr/adr-0005-contabo-credentials-and-token.md) (`ADR-0005`)
- [Power actions, operation tracking and confirmation](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/adr/adr-0006-power-actions-and-operation-tracking.md) (`ADR-0006`)

## Verification and quality

- [Provider API Verification](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/provider-api-verification.md) — what the provider documentation, the mocks and live runs confirm
- [Artifact Registry](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/artifact-registry.md) — the next ID of each artifact type
- [Traceability Matrix](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/sqa/traceability-matrix.md)
- [SQA review records](https://git.tirsystem.com/TirSystem/iac-node-forge/src/branch/main/docs/sqa/reviews) — one `RC-NNN` record per review

## Guides

The guides in this wiki are in the sidebar: the [Proxmox VE integration test](Integration-Test),
the [Contabo live test](Contabo-Live-Test) and the [power control live test](Power-Control-Live-Test).
