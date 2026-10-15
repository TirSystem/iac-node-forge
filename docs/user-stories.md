# User Stories

## Metadata
| Key | Value |
| --- | --- |
| ID | US-001 |
| CrossReference | [BC-001], [MIL-001], [UC-001], [UC-002], [UC-003], [UC-004], [UC-006], [UC-007], [UC-008], [UC-012], [UC-016], [UC-017], [UC-018], [UC-019] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Added stories US-001.09 to US-001.12 for backup and restore | [31933c9] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-009 | pending |

---

## Purpose and Scope

Stories for the Must use cases of [MIL-001]: UC-001, UC-002, UC-003, UC-004, UC-006, UC-007, UC-008 and UC-012, and the backup use cases UC-016 to UC-019. The only actor is DevOps. Each story traces to one use case.

## Story List

### US-001.01 — Configure and validate provider access

**As a** DevOps, **I want** to configure a provider and check that its access works, **so that** I know the product can reach the provider before I rely on it.

**Acceptance Criteria**

- Given a reachable provider and valid credentials, when I configure the provider, then the result states that access works and the configuration is saved without any secret.
- Given invalid or expired credentials, when I validate, then the result states the reason and nothing is saved as valid.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-001] | fits one iteration | none |

### US-001.02 — Discover capabilities and server options

**As a** DevOps, **I want** to see what a provider and target can do and offer, **so that** I only define servers the provider can actually provide.

**Acceptance Criteria**

- Given validated access, when I ask for capabilities, then regions or nodes, images, sizes and supported actions are listed for that provider.
- Given an action the provider does not support, when I view capabilities, then it is shown as unsupported.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-002] | fits one iteration | none |

### US-001.03 — Define desired server configuration

**As a** DevOps, **I want** to describe the server I want as a named configuration, **so that** provisioning is repeatable and checkable before anything is created.

**Acceptance Criteria**

- Given known capabilities, when I define a server with a supported size and image, then it is saved as valid under a name.
- Given a choice the provider does not support, when I define the server, then it is reported and not saved as valid.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-003] | fits one iteration | none |

### US-001.04 — Provision a server

**As a** DevOps, **I want** to create a server from a desired configuration, **so that** I get the server I described with the consequences made clear.

**Acceptance Criteria**

- Given a valid configuration, when I request provisioning, then I am shown what will be created and its cost consequence and must confirm before anything is sent.
- Given a confirmed request, when the provider finishes, then the server is recorded as managed by this client and the outcome is recorded.
- Given a failed request, when it ends, then the state left at the provider is reported.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-004] | fits one iteration | none |

### US-001.05 — Track long-running operations

**As a** DevOps, **I want** to see the status and outcome of operations that take time, **so that** I know whether an action finished, failed or is still running.

**Acceptance Criteria**

- Given a submitted operation, when it is running, then its status is available.
- Given an operation that ended, when I look at it, then its outcome and cause are shown and recorded.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-006] | fits one iteration | none |

### US-001.06 — List and inspect servers

**As a** DevOps, **I want** to see my servers across providers, including ones this client did not create, **so that** I know what exists and what this client manages.

**Acceptance Criteria**

- Given configured providers, when I list servers, then each server shows its provider, state, size and addresses.
- Given a server not created by this client, when I list servers, then it is marked as not managed by this client.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-007] | fits one iteration | none |

### US-001.07 — Start, stop and restart a server

**As a** DevOps, **I want** to control a server's power state, **so that** I can operate servers without using the provider's console.

**Acceptance Criteria**

- Given a server and a supported action, when I request it, then the resulting state is reported.
- Given a forced action or a server not managed by this client, when I request it, then an extra confirmation is required first.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-008] | fits one iteration | none |

### US-001.08 — Delete or cancel a server

**As a** DevOps, **I want** to remove a server according to what the provider does, **so that** I understand and accept the consequence before it happens.

**Acceptance Criteria**

- Given a server, when I request removal, then I am told whether it is destroyed now or cancelled with an effective date, and must confirm.
- Given a server not managed by this client, when I request removal, then an extra confirmation is required.
- Given a completed removal, when it ends, then the consequence is recorded with the operation.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-012] | fits one iteration | none |

### US-001.09 — Back up server files to the local PC

**As a** DevOps, **I want** to copy files from a server to my local PC, **so that** I keep my own copy of the server's data.

**Acceptance Criteria**

- Given a running server and a destination, when I back up chosen files, then the data is copied and verified complete and nothing on the server is changed.
- Given a destination without enough room, when I start the backup, then it is refused with the reason.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-016] | fits one iteration | none |

### US-001.10 — Restore files from the local PC to the server

**As a** DevOps, **I want** to copy files from my local PC to a server, **so that** I can put data back or place new data on the server.

**Acceptance Criteria**

- Given data on the local PC, when I restore to a server, then I am told what would be overwritten and must confirm before anything is copied.
- Given a completed restore, when it ends, then the copy is verified complete and the result is reported.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-017] | fits one iteration | none |

### US-001.11 — Back up a whole server

**As a** DevOps, **I want** to back up a whole server, **so that** I can recover it if it is lost or damaged.

**Acceptance Criteria**

- Given a provider that supports it, when I request a backup, then it is followed to completion and I am told where it is kept.
- Given a provider that does not support it, when I request a backup, then it is shown as unsupported.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-018] | fits one iteration | none |

### US-001.12 — Restore a whole server from a backup

**As a** DevOps, **I want** to restore a whole server from a backup, **so that** a lost or damaged server is recovered.

**Acceptance Criteria**

- Given a backup, when I request a restore, then I am told what it will replace and must confirm.
- Given a completed restore, when it ends, then the state of the server is reported and recorded.

| Traces to | Size | INVEST exceptions |
| --- | --- | --- |
| [UC-019] | fits one iteration | none |

## INVEST Check

Each story is independent of the others in intent, negotiable in wording, valuable to DevOps, estimable, small enough for one iteration and testable through its Given/When/Then criteria. Exception: UC-004 and UC-012 depend on UC-006 for the outcome, which is stated in their use cases.

---

[MIL-001]: ./milestones/mil-001-use-case-baseline.md
[UC-001]: ./use-cases/uc-001/uc.md
[UC-002]: ./use-cases/uc-002/uc.md
[UC-003]: ./use-cases/uc-003/uc.md
[UC-004]: ./use-cases/uc-004/uc.md
[UC-006]: ./use-cases/uc-006/uc.md
[UC-007]: ./use-cases/uc-007/uc.md
[UC-008]: ./use-cases/uc-008/uc.md
[UC-012]: ./use-cases/uc-012/uc.md
[UC-016]: ./use-cases/uc-016/uc.md
[UC-017]: ./use-cases/uc-017/uc.md
[UC-018]: ./use-cases/uc-018/uc.md
[UC-019]: ./use-cases/uc-019/uc.md
[31933c9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/31933c95a83dd3e114cc067cd907ddddb750b1bb
