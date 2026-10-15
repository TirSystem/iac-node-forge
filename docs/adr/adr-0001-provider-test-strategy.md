# Provider test strategy

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0001 |
| CrossReference | [BC-001], [MIL-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Recorded the runner spike results and chose the in-process mock for CI | [704c593] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Decision shortened to two sentences with the detail kept below it<br>Accepted after RC-004 | [b664ca3] |

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
- **Gitea CI** is available. A spike on 2026-10-15 (Gitea 1.27.3, act_runner
  v3.5.0, labels `ubuntu-latest`, `ubuntu-24.04`, `ubuntu-22.04`) showed that a
  job runs in a container (`docker.gitea.com/runner-images:ubuntu-latest`,
  Ubuntu 24.04) with the Docker socket mounted and Docker 29.7.2 reachable.
  All four spike jobs passed: environment report, an in-process HTTP server,
  running a container from the job, and a service container reached by its
  name (`http://mock:80/`). The runner image provides Python 3.12.3, while the
  CLI targets Python 3.13.
- Two clients (Python CLI, WinUI 3) share the same use cases, so provider
  behaviour is best tested once, below the clients.

Options considered:

1. Test only against live providers. Rejected: cost on Contabo, and no CI.
2. Run Proxmox VE in Docker. Rejected: unsupported and unreliable.
3. Layered tests: fakes, a mock provider API, a Proxmox VE VM, read-only
   live smoke tests on Contabo.

## Decision

Test providers in layers: fakes for unit tests, a mock provider API for contract tests in Gitea CI, a Proxmox VE VM outside CI for integration tests, and only read-only calls against live Contabo. The mock runs in CI as an in-process HTTP server, and no create, update or delete runs against live Contabo in automated tests.

### Details

Use layered tests. Unit tests use fakes behind the provider interface.
Contract tests run both providers against a mock provider API in Gitea CI,
including failure cases. Integration tests run against a Proxmox VE VM on the
Product Owner's machine, outside CI. Contabo is tested live only with
read-only calls, on demand. No create, update or delete runs against live
Contabo in automated tests; a real change is a manual acceptance by S01 with
the cost approved first.

The mock runs in CI as an in-process HTTP server started by the test run.
It needs no image pull, runs the same way on a developer machine and on any
CI host, and was shown to work on the Gitea runner. A service container is
supported by the runner and may be added where a test needs container-level
realism, but it is not the default. The Python version used in CI is set
explicitly in the workflow, because the runner image ships 3.12 and the CLI
targets 3.13.

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

**Open item:** the Python 3.13 toolchain on the runner (the image has 3.12.3)
is not yet set up; the first CI workflow for the CLI has to install it.

## Affected Artifacts

- [BC-001] — Constraints and Risks reflect this decision.
- [MIL-001] — task 7 delivers this ADR; Go criterion 4 requires it accepted.

---

[BC-001]: ../business-case.md
[MIL-001]: ../milestones/mil-001-use-case-baseline.md
[704c593]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/704c5936323131397b0d4b17e36056d4e84e123c
[b664ca3]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/b664ca34d52e7c4fe1561279e213dd6ffbeca3d5
