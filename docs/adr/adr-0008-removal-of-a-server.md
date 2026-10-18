# Removal of a server

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0008 |
| CrossReference | [BC-001], [MIL-005], [MIL-006], [ADR-0002], [ADR-0005], [ADR-0006], [ADR-0007], [UC-006], [UC-012] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-083 | pending |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Removal is the first action of the product that cannot be undone, and the two providers mean
different things by it ([UC-012]). The verification note shows how:

- **Proxmox VE** destroys the virtual machine or container at once.
  `DELETE /nodes/{node}/lxc/{vmid}` or `.../qemu/{vmid}` with the options `purge` and
  `destroy-unreferenced-disks` answers with a task, and the permission `VM.Allocate` is needed
  (P10, P13). A running machine cannot be deleted without being stopped first.
- **Contabo** does not delete. `POST /v1/compute/instances/{id}/cancel` records a request to
  cancel: the instance gets the status `cancelled` and a `cancelDate`, and the contract, with its
  billing, runs on until then (C14). The rule that sets the date, for example the end of the
  contract period, is not stated by the provider, so the date cannot be predicted before the
  request. There is no task, and cancelling an instance that is already cancelled is not
  something to repeat.

The existing ports are read-only ([ADR-0002]), four power actions ([ADR-0006]) and creation
([ADR-0007]). The user story asks that DevOps is told "whether it is destroyed now or cancelled
with an effective date" and must confirm, that a server not managed by this client needs an extra
confirmation, and that the consequence is recorded with the operation (US-001.08). A wrong
removal destroys data or commits an account to a cancellation that this product cannot withdraw.

Options considered for the capability and the port:

1. **Add `remove` to `ServerPowerPort`.** One port for every action on a server, but a removal is
   then reachable wherever a power action is, and the test that lists the write requests loses its
   meaning.
2. **A separate narrow `ServerRemovalPort`** that the adapters also implement, like
   `ServerProvisionPort`. The write surface of removal is two requests, reachable only through
   one capability, and read-only and power code cannot reach it by type.
3. **One generic "delete" that hides the difference.** Simple to read, and exactly what makes a
   Contabo cancellation look like a deletion; the consequence the user must accept would be lost.

Options considered for the protection:

1. **Confirm like a power action** (one yes, the identifier only for an unmanaged server). The
   same wording for a restart and for a destruction invites a habitual yes.
2. **Always type the identifier, and one more confirmation for an unmanaged server.** The user
   names exactly what is destroyed; a display name, a prefix or a neighbouring identifier does not
   match.
3. **Stop a running server on the user's behalf and then delete it.** Convenient, but it adds a
   power request nobody asked for to a destructive action.

Options considered for the record kept after a removal: delete the managed-server record, or end
it. Deleting loses the history that a server was managed here (and which removal ended it);
Proxmox VE reuses a freed identifier, so a later server of the same identifier must not be
confused with the removed one.

## Decision

Removal is a separate `ServerRemovalPort`, implemented by the Proxmox VE and Contabo adapters,
with the capability `remove_server` and two removal kinds, `DESTROY` and `CANCEL`; the consequence
text of the kind is shown before anything is sent and recorded with the operation, the server
identifier is always typed, an unmanaged server needs one more confirmation, a running Proxmox VE
server is refused and never stopped on the user's behalf, and a server already removed is reported
without a request. When the operation succeeds the managed-server record is ended, not deleted,
and the write surface grows by exactly the Proxmox VE delete and the Contabo cancel.

### Rules

- **Port and capability:** `ServerRemovalPort`, beside `ProviderPort`, `ServerPowerPort` and
  `ServerProvisionPort`, with the capability `remove_server`; a provider that does not declare it
  is reported as unsupported before any request. The port states its `RemovalKind`, says whether
  a given server may be removed now (`RemovalBlock`), gives the consequence text, sends the one
  removal request and reads the state of its operation.
- **Operations:** a removal is an `Operation` like a power action, with the new action value
  `REMOVE`. The type keeps the name `PowerAction`, as it did for `PROVISION` ([ADR-0007]); the
  state rules of [ADR-0006] apply and the operation is followed like any other ([UC-006]).
  `ControlServerPower` refuses `REMOVE`, and `ProvisionServer` is not affected.
- **Removal kinds:**
  - `DESTROY` (Proxmox VE): the delete request with `purge=1` and
    `destroy-unreferenced-disks=1` for a container (`lxc`) or a virtual machine (`qemu`); the
    task is polled until `stopped` and `OK` is `succeeded`, any other exit status is `failed`.
    The consequence says that the machine is destroyed now and its disks are released.
  - `CANCEL` (Contabo): the cancel request, then the instance is read until its status is
    `cancelled`; the `cancelDate` the provider reports is the effective date. A status that is not
    final, or a time limit that passes, ends the operation as `unknown`, never as success.
- **Cancel date rule (open in the provider specification, decided here for the product):** the
  product does not compute, predict or promise a date. Before the request the consequence says
  that a cancellation is requested at Contabo, that the instance and its billing continue until the
  effective date, that the date is the one the provider reports after the request, and that this
  product cannot withdraw a cancellation. After the request the reported date is shown and
  recorded in the `detail` of the operation. If the provider reports no date, the result says so;
  the status `cancelled` is final, so the operation still `succeeded`. The verification note records what the rule turned out to
  be when it can be read (C14).
- **Consequence text:** `consequence(configuration, server)` on the port returns the text that is
  shown before the confirmation; the same text is recorded with the operation in a new bounded
  field `consequence` (at most 500 characters), not in `detail`. `detail` is overwritten while an
  operation is followed and carries the outcome and, for a cancellation, the effective date; the
  consequence is what the user accepted and must stay as shown.
- **Protection:**
  - The server identifier is always typed, for every removal: interactively it is retyped at the
    prompt; in a non-interactive run `--yes` is required and the identifier argument is the typed
    identifier. It must equal the provider's identifier exactly; a display name or a prefix is not
    accepted and nothing is sent.
  - A server not managed by this client needs one more confirmation, the identifier typed again;
    non-interactively `--confirm-unmanaged <identifier>` as well as `--yes`.
  - A running Proxmox VE server is refused before any request, with the instruction to shut it
    down first (`ControlServerPower`); the product never stops it on the user's behalf.
  - A server that is already removed (a Contabo instance already `cancelled`) is reported as
    already in that state with no request; a Proxmox VE server that does not exist is reported as
    not found.
  - Without a valid confirmation nothing is sent and nothing is recorded.
- **No duplicate-protection record:** unlike a creation, a repeated removal cannot create or bill a
  second thing: a retry meets the new state (not found, or already cancelled). A timeout or a lost
  answer ends the operation as `unknown` and the request is not repeated.
- **After a successful removal:** the `ManagedServerRecord`, if the server was managed, is ended,
  not deleted: it keeps an end time and the operation that ended it, and no longer counts as
  managed. Its key includes the recorded time, so a Proxmox VE identifier that is reused later is a
  new record. The operation keeps its consequence. Nothing else is deleted: no operation, no
  desired configuration, no intent.
- **Write allow-list:** the four power POSTs, the Proxmox VE `lxc` and `qemu` creations, the Contabo
  instance creation and its token POST, the Proxmox VE `DELETE` of an `lxc` or `qemu` resource and
  the Contabo `cancel` POST. Nothing else: no snapshot, reinstall, rescue, resize or clone. A test
  lists the write requests the mocks can receive.
- **No secret:** the consequence, the operation record and the ended managed-server record never
  hold a credential, a token or a key value; an error text for a 401 or 403 names the permission
  (`VM.Allocate`), not a header ([ADR-0005]).
- **Not covered:** adoption of an unmanaged server, bulk removal, undoing a Contabo cancellation
  (it needs the provider's own interface), and the stopping of a running server.

## Consequences

**Positive:**

- The user is told what will happen, in the provider's own terms, before anything is sent, and the
  text is kept with the operation as the evidence of what was accepted.
- Typing the identifier every time makes an accidental or batched removal hard; an unmanaged
  server needs a second, separate act.
- The removal write surface is two named requests behind one capability, and the allow-list stays
  small and testable ([ADR-0006], [ADR-0007]).
- The history of managed servers is kept, and a reused Proxmox VE identifier cannot be confused
  with the removed server.
- The test-only delete helper of the live provisioning test of [MIL-005] is replaced by the
  product's own removal, so the live test exercises the product.

**Negative:**

- The Contabo effective date is known only after the request, so the confirmation cannot show it,
  and the cancellation cannot be withdrawn by this product.
- Typing the identifier every time is slower, also for a server created by this client.
- A running Proxmox VE server must be shut down in a separate step.
- A third narrow port per adapter, and the resolver must give it.
- The Contabo cancellation is exercised only against the mock; its real status sequence and date
  rule are unverified, and no Contabo instance is cancelled in a live run.
- The managed-server key now contains the recorded time, and the file keeps ended records for
  good.

## Affected Artifacts

- [BC-001] — Objectives 1 to 3.
- [MIL-006] — task 1 delivers this ADR; Go criterion 1 requires it reviewed.
- [ADR-0002] — the capability model gains the capability `remove_server`, a third write port and
  the removal kinds.
- [ADR-0005] — the Contabo token and request identifier apply to the cancel request.
- [ADR-0006] — operations are followed as before; the write allow-list and the confirmation rules
  are extended for a removal.
- [ADR-0007] — the write allow-list grows by two requests, and the test-only delete helper of its
  live test is replaced.
- [UC-012] — the use case this decision realises.

---

[BC-001]: ../business-case.md
[MIL-006]: ../milestones/mil-006-delete-or-cancel.md
[MIL-005]: ../milestones/mil-005-provisioning.md
[ADR-0002]: ./adr-0002-provider-capability-model.md
[ADR-0005]: ./adr-0005-contabo-credentials-and-token.md
[ADR-0006]: ./adr-0006-power-actions-and-operation-tracking.md
[ADR-0007]: ./adr-0007-desired-configuration-and-provisioning.md
[UC-006]: ../use-cases/uc-006/uc.md
[UC-012]: ../use-cases/uc-012/uc.md
