# Power actions, operation tracking and confirmation

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0006 |
| CrossReference | [BC-001], [MIL-004], [ADR-0002], [ADR-0005], [UC-006], [UC-008], [UC-013] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-055 | pending |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Start, graceful shutdown, hard stop and restart are the first actions of the product that
change a server's state ([UC-008]). Each takes time, so the product follows it ([UC-006]).
The verification note shows how differently the two providers behave:

- **Proxmox VE** answers each power request with a task identifier (UPID). The task has a
  status `running` or `stopped` and an exit status; success is an exit status of `OK` (P3,
  P4, P7). The request needs the `VM.PowerMgmt` permission (P13).
- **Contabo** has no task resource. The request answers with the instance, whose `status`
  then changes; `stop` powers off, `shutdown` sends an ACPI event, and stopping a stopped
  instance does nothing (C7, C8, C10).

The existing port ([ADR-0002]) is read-only and used by every use case. A wrong power action
can cause downtime or data loss, and no server is recorded as managed by this client yet.

Options considered:

1. **Add the four operations to `ProviderPort`.** One interface, but every read-only
   consumer and fake must then know about writes, and the "no write is reachable" safeguard
   cannot be shown by the type.
2. **A separate narrow `ServerPowerPort`** that the adapters also implement, and an
   `OperationStore` port for the record. Read-only code cannot reach a write by type, and the
   write surface is exactly four operations.
3. **Generic "action" with a name and parameters.** Flexible, and exactly what makes later
   destructive actions easy to reach by accident.

## Decision

Power actions are four fixed values behind a separate `ServerPowerPort` that the Proxmox VE
and Contabo adapters implement, each request returns an operation that is followed until it
ends and is recorded without any secret, and every action needs a confirmation before a
request is sent, with an extra confirmation for a server not managed by this client. A
server already in the requested state is reported and no request is sent.

### Rules

- **Actions and capabilities:** `start`, `shutdown` (graceful), `stop` (hard) and `restart`;
  the capabilities are `start_server`, `shutdown_server`, `stop_server` and
  `restart_server`; an action the adapter does not declare is reported as unsupported.
- **Following an operation:**
  - Proxmox VE: poll the task until its status is `stopped`; `OK` is `succeeded`, any other
    exit status `failed` with the exit status as the detail.
  - Contabo: poll the instance status until it equals the target (`running` after `start`,
    `stopped` after `shutdown` and `stop`) or the time limit passes. For `restart` a
    transition cannot be told apart from no change, so it is `succeeded` only when the
    status is `running` at the end of a short settle time, and the detail says that the
    transition was not observed.
  - The time limit defaults to 120 seconds and the poll interval to 2 seconds; both are
    options. A limit that passes ends the operation as `unknown`, never as success; the
    request is not repeated.
- **Operation states:** `running`, `succeeded`, `failed`, `unknown`.
- **Confirmation:** one confirmation for every action, which states the action and, for
  `stop` and `restart`, that unsaved data may be lost; for a server not managed by this
  client the identifier must also be typed. A non-interactive run needs `--yes` and, for an
  unmanaged server, `--confirm-unmanaged <identifier>`; no request is sent without them.
- **Already in state:** the current state is read first; `start` on a running server and
  `shutdown` or `stop` on a stopped one are reported as already in the requested state, with
  no request and no operation record.
- **Record:** one operation record per request (identifier, configuration, server, action,
  state, start and end time, provider reference such as the UPID, and a bounded detail
  text). It never holds a credential, a token or a header.
- **No other write:** the adapters have no code path for delete, cancel, reinstall, rescue,
  snapshot or create; a test lists the write requests the mocks can receive.

## Consequences

**Positive:**

- Read-only code and its fakes cannot reach a write by type; the write surface is four
  named operations ([ADR-0002]).
- An unknown outcome is shown as unknown, so a timeout is never read as success.
- The confirmation and the allow-list of writes are testable criteria of the milestone.
- The record lets a later milestone list and recover operations ([UC-013]).

**Negative:**

- Two ports per adapter, and the resolver must give both.
- Contabo can only be followed by its status, so a quick restart and a failure to restart
  look alike; the detail says so, and a real task model would need a provider change.
- Reading the state first adds one request and a race: the state can change between the
  read and the request.
- Every action asks for confirmation, including `start`, which is the most careful choice
  and the most tedious one.

## Affected Artifacts

- [BC-001] — Objectives 1 to 3.
- [MIL-004] — task 1 delivers this ADR; Go criterion 1 requires it reviewed.
- [ADR-0002] — the capability model is extended with four capabilities and a second port.
- [ADR-0005] — the Contabo token and request identifier apply to the power requests.
- [UC-006], [UC-008] — the use cases this decision realises.

---

[BC-001]: ../business-case.md
[MIL-004]: ../milestones/mil-004-power-control.md
[ADR-0002]: ./adr-0002-provider-capability-model.md
[ADR-0005]: ./adr-0005-contabo-credentials-and-token.md
[UC-006]: ../use-cases/uc-006/uc.md
[UC-008]: ../use-cases/uc-008/uc.md
[UC-013]: ../use-cases/uc-013/uc.md
