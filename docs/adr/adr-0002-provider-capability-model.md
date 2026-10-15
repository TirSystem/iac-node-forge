# Provider capability model

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0002 |
| CrossReference | [BC-001], [MIL-001], [ADR-0001], [UC-002], [UC-004], [UC-008], [UC-009], [UC-012], [UC-014], [UC-015] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Deprecated | Jens Tirsvad Nielsen | S02 | Initial version | [cd7ca06] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Decision shortened to two sentences; affected use cases linked<br>Accepted after RC-005 | [b664ca3] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Proxmox VE and Contabo do not expose identical capabilities or lifecycle
semantics. Examples from the candidate use cases, to be verified in
MIL-001 task 4:

- Removing a server: Proxmox VE destroys it; Contabo cancels it, with the
  effect expected at the end of the billing period.
- Long-running operations: Proxmox VE has a task API; Contabo may have no
  equivalent.
- Snapshots: availability depends on the Proxmox VE storage type and on the
  Contabo plan.
- Bootstrap: cloud-init support differs.

Which capabilities exist can also depend on the target, not only the
provider (a Proxmox VE node and its storage, a Contabo product). The Python
CLI and the WinUI 3 application must support the same use cases, so
provider differences must be decided once, below the clients.

Options considered:

1. **Lowest common denominator:** expose only what both providers do. Rejected:
   hides real, useful behaviour and misstates semantics (a cancel shown as a
   delete).
2. **Provider-specific commands and screens:** a separate flow per provider.
   Rejected: duplicates use cases and breaks the rule that both clients
   support the same use cases.
3. **One provider interface with declared capabilities and explicit
   semantics:** each provider adapter implements a common interface and
   declares what it supports, and results describe what actually happened.

## Decision

Each provider adapter implements one common interface and declares its capabilities, and use cases check a capability before offering or running an action. Where an action means different things at different providers, the result carries the provider's real semantics.

### Details

Use option 3. Each provider adapter implements one common interface for the
use cases and declares a set of capabilities, discovered per provider and per
target where it depends on one ([UC-002]). Use cases check a capability before
offering or running an action, and an unsupported action is reported as
unsupported, never faked. Where the meaning of an action differs, the result
carries the provider's real semantics, for example a removal outcome that
says "destroyed now" or "cancelled, effective on a stated date". Use cases
stay the same for both providers; variants live inside the adapters.

## Consequences

**Positive:**

- One set of use cases serves both providers and both clients.
- Provider differences are visible to the user and recorded, not hidden.
- A further provider is added by writing an adapter and declaring its
  capabilities.
- Capability checks are testable with the fakes and mock providers of
  [ADR-0001].

**Negative:**

- The interface and the capability list must be designed carefully and may
  change as the providers are studied.
- Clients must render capability-dependent behaviour (hidden or disabled
  actions, varying confirmation text).
- Dynamic capabilities per target add discovery calls and caching decisions.

## Affected Artifacts

- [BC-001] — Objective 2 (explicit provider behaviour).
- [MIL-001] — task 5 delivers this ADR; Go criterion 4 requires it accepted.
- [ADR-0001] — contract tests exercise capability declarations.
- [UC-002], [UC-004], [UC-008], [UC-009], [UC-012], [UC-014], [UC-015] — depend on the capability checks.

---

[BC-001]: ../business-case.md
[MIL-001]: ../milestones/mil-001-use-case-baseline.md
[ADR-0001]: ./adr-0001-provider-test-strategy.md
[cd7ca06]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/cd7ca06b28cdb5ab7298312602798e2b861bc908
[UC-002]: ../use-cases/uc-002/uc.md
[UC-004]: ../use-cases/uc-004/uc.md
[UC-008]: ../use-cases/uc-008/uc.md
[UC-009]: ../use-cases/uc-009/uc.md
[UC-012]: ../use-cases/uc-012/uc.md
[UC-014]: ../use-cases/uc-014/uc.md
[UC-015]: ../use-cases/uc-015/uc.md
[b664ca3]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/b664ca34d52e7c4fe1561279e213dd6ffbeca3d5
