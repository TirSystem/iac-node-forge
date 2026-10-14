# Provider test strategy

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0001 |
| CrossReference | [BC-001], [MIL-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [cd7ca06] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

iac-node-forge manages servers at Proxmox VE and Contabo through their
provider APIs. Testing against live providers has limits:

- **Contabo** charges for servers. Create, update and delete calls against the
  live account cost money and are forbidden in automated tests
  ([BC-001], Constraints).
- **Proxmox VE** is a full distribution with a hypervisor. It cannot run
  reliably in a plain Docker container and is too heavy for the Gitea CI
  runners. A Proxmox VE VM is available on the Product Owner's own machine.
- **Gitea CI** is available, but whether its runners support Docker, service
  containers or Docker-in-Docker is not known and has not been tested.
- Two clients (Python CLI, WinUI 3) share the same use cases, so provider
  behaviour is best tested once, below the clients.

Options considered:

1. Test only against live providers. Rejected: cost on Contabo, and no CI.
2. Run Proxmox VE in Docker. Rejected: unsupported and unreliable.
3. Layered tests: fakes, a mock provider API, a Proxmox VE VM, read-only
   live smoke tests on Contabo.

## Decision

Use layered tests. Unit tests use fakes behind the provider interface.
Contract tests run both providers against a mock provider API in Gitea CI,
including failure cases. Integration tests run against a Proxmox VE VM on the
Product Owner's machine, outside CI. Contabo is tested live only with
read-only calls, on demand. No create, update or delete runs against live
Contabo in automated tests; a real change is a manual acceptance by S01 with
the cost approved first.

How the mock runs in CI (service container, Docker, or an in-process HTTP
server in the test run) is decided by a spike on the Gitea runner. If the
runner has no Docker support, the in-process server is used, because it needs
no container.

## Consequences

**Positive:**

- No cost on Contabo from automated tests.
- CI runs without a hypervisor and gates merges on contract tests.
- Real Proxmox VE semantics (tasks, snapshots, deletion) are tested on an
  actual Proxmox VE.
- Failure cases such as expired tokens and slow operations can be scripted.

**Negative:**

- The mock can drift from the real providers; drift is only caught by the VM
  integration tests and the read-only Contabo smoke tests.
- Proxmox VE integration tests depend on one machine and are not part of CI.
- Contabo create, update and delete behaviour is only verified by mock and
  manual acceptance, never automatically.
- The mock needs building and maintaining for both providers.

**Open item:** the Gitea runner's Docker support is untested; [MIL-001] task 8 covers the spike.

## Affected Artifacts

- [BC-001] — Constraints and Risks reflect this decision.
- [MIL-001] — task 7 delivers this ADR; Go criterion 4 requires it accepted.

---

[BC-001]: ../business-case.md
[MIL-001]: ../milestones/mil-001-use-case-baseline.md
[cd7ca06]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/cd7ca06b28cdb5ab7298312602798e2b861bc908
