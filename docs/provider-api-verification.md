# Provider API Verification

## Metadata
| Key | Value |
| --- | --- |
| Task | [MIL-001] task 4, verify provider API behaviour |
| Author | Jens Tirsvad Nielsen (drafted with the AI assistant) |
| Retrieved | 2026-10-15 |
| Status | Draft, not a registered artifact type |

This note is not a registered artifact type in the framework catalog. It feeds
the use cases, [ADR-0002] and [ADR-0003]. Whether the framework should get a
type for it is an upstream question.

## Sources

| Provider | Source | How it was read |
| --- | --- | --- |
| Proxmox VE | `https://pve.proxmox.com/pve-docs/api-viewer/apidoc.js` (the API viewer's schema; 454 paths) | Downloaded and parsed |
| Contabo | `https://api.contabo.com/` (OpenAPI 3.0.3, "Contabo API" 1.0.0, 102 paths) | Spec embedded in the page, downloaded and parsed |

The verdict column uses: **Verified** (stated in the source), **Partly** (the
source states part of it), **Not stated** (not in the source; remains an
assumption), **Differs** (the source contradicts the assumption in a use case).
Nothing was tested against a live server.

## Proxmox VE

| # | Statement | Verdict | Evidence |
| --- | --- | --- | --- |
| P1 | Authentication by ticket exists | Verified | `POST /access/ticket` |
| P2 | API tokens exist and are sent as `Authorization: PVEAPIToken=USER@REALM!TOKENID=SECRET` | Verified (live) | Token management paths exist in the API viewer; the header form is not there, but the adapter's integration tests passed against a real Proxmox VE with it (see Live run). |
| P3 | Long-running actions return a task ID | Verified | Create, delete, power and snapshot calls return a string (the task ID, UPID) |
| P4 | A task has a status and an exit status | Verified | `GET /nodes/{node}/tasks/{upid}/status` returns `status` (`running` or `stopped`) and optional `exitstatus`; `/tasks/{upid}/log` exists |
| P5 | Nodes, storage and resources can be discovered | Verified | `/nodes`, `/nodes/{node}/storage`, `/nodes/{node}/storage/{storage}/content`, `/cluster/resources`, `/cluster/nextid` |
| P6 | VMs and containers can be created | Verified | `POST /nodes/{node}/qemu`, `POST /nodes/{node}/lxc`, clone via `.../qemu/{vmid}/clone` |
| P7 | Power actions: start, graceful shutdown, hard stop, reboot, reset, suspend | Verified | `status/start`, `shutdown`, `stop`, `reboot`, `reset`, `suspend` |
| P8 | Snapshots exist for VMs and containers, with rollback | Verified | `.../snapshot`, `.../snapshot/{snapname}/rollback` for qemu and lxc; snapshot create has an optional `vmstate` |
| P9 | Snapshot support depends on the storage type | Not stated | Not in the schema |
| P10 | Delete destroys the VM immediately | Verified | `DELETE /nodes/{node}/qemu/{vmid}` (and lxc) with options `purge` and `destroy-unreferenced-disks`; returns a task ID |
| P11 | Cloud-init configuration can be set | Partly | `/nodes/{node}/qemu/{vmid}/cloudinit` and `config` exist. Whether the template has a cloud-init drive is not stated. |
| P12 | Resize is a disk and configuration edit | Verified | `PUT .../qemu/{vmid}/resize` (disk), `config` (CPU and memory); `PUT .../lxc/{vmid}/resize` |
| P13 | Operations require specific permissions | Verified | For example `VM.Allocate` (create, delete), `VM.PowerMgmt` (power), `VM.Snapshot` (snapshot) |

## Contabo

| # | Statement | Verdict | Evidence |
| --- | --- | --- | --- |
| C1 | Authentication uses four values | Verified | OAuth2 password grant against `auth.contabo.com` with client ID, client secret, API user and API password; the result is a Bearer `access_token` |
| C2 | Token lifetime and renewal | Not stated | No expiry in the spec |
| C3 | Every request needs a request ID | Verified | Header `x-request-id` (UUID version 4) is required on instance calls; `x-trace-id` is optional |
| C4 | The account's instances can be listed | Verified | `GET /v1/compute/instances` |
| C5 | Create takes a contract period | **Differs** | `period` is the only required field: 1, 12 or 24 months. Provisioning commits to a billing period, so the cost confirmation in [UC-004] must show the period. |
| C6 | Create accepts image, product, region, SSH keys, cloud-init | Verified | `imageId`, `productId`, `region` (EU, US-central, US-east, US-west, SIN, UK, AUS, JPN, IND), `sshKeys` (secret IDs), `userData` (cloud-init), `defaultUser` |
| C7 | There is no task or operation resource | Verified | No task, operation, job or event path among the 102 paths. State is the instance `status`. |
| C8 | Instance status values | Verified | provisioning, installing, running, stopped, error, rescue, reset_password, pending_payment, verification_required, uninstalled, manual_provisioning, product_not_available, unknown, other |
| C9 | A history of actions exists | Verified | `GET /v1/compute/instances/actions/audits` and `/instances/audits` |
| C10 | Power actions: start, stop, restart, shutdown | Verified | `stop` is a power-off and data may be lost; `shutdown` sends an ACPI event for a clean shutdown; stopping a stopped instance does nothing |
| C11 | Snapshots: create, list, delete, rollback | Verified | Name up to 30 characters, description up to 255; a snapshot has `autoDeleteDate` |
| C12 | Rollback to an older snapshot deletes newer ones | **Differs** | Documented: rolling back to a snapshot that is not the latest deletes all newer snapshots of the instance. [UC-009] needs to warn about it. |
| C13 | Number of snapshots allowed | Not stated | No limit found in the spec |
| C14 | Cancel is a request to cancel, with a date | Partly | `POST .../cancel` sets status `cancelled`; the instance has a `cancelDate` ("the date on which the instance will be cancelled"). The rule for that date (for example end of the period) is not stated. |
| C15 | Reinstall exists | Verified | `PUT /v1/compute/instances/{instanceId}` with a new image, SSH keys, root password or cloud-init |
| C16 | Rescue mode exists | Verified | `POST .../actions/rescue` |
| C17 | Resize or upgrade | Partly, inconsistent | `POST .../upgrade` is described as add-ons only (firewall, private network), while `GET .../products/available` says it lists products the instance can be upgraded to, to be submitted with an `offerId`. The spec contradicts itself. |
| C18 | Secrets (SSH keys, passwords) are managed through the API | Verified | `/v1/secrets` with types `password` and `ssh` |
| C19 | Rate limiting exists | Verified | Status 429 is documented; the limits are not |
| C20 | Server-side tags exist | Verified | `/v1/tags` and assignments. Usable as a provider-side marker if the Product Owner later wants one. |

## Contabo adapter (MIL-003)

What the read-only Contabo adapter assumes, and what has been shown for each point. "Mock"
means the in-process mock of `iac-node-forge-py`; "live" means a run against a real account
(MIL-003 task 12, done on 2026-10-15).

| # | Statement the adapter relies on | Documentation | Mock | Live |
| --- | --- | --- | --- | --- |
| A1 | The four values are exchanged at the authentication address with `grant_type=password`, `client_id`, `client_secret`, `username` (API user) and `password` (API password) | Yes (C1) | Yes | Passed |
| A2 | The answer holds an `access_token`, sent as `Authorization: Bearer` | Yes (C1) | Yes | Passed |
| A3 | A wrong password is rejected with 400 or 401 | Not stated | Assumed | Rejected as a failed result; the status code was not recorded |
| A4 | The token lifetime is not stated; the adapter renews once after a 401 | Not stated (C2) | Yes (expiry switch) | Not observed: no expiry within the run |
| A5 | Every API call sends a UUID version 4 `x-request-id`; the token request does not | Yes (C3) | Yes | Passed (calls accepted) |
| A6 | Lists take `page` and `size`, answer a `data` array and `_pagination`; 100 per page is accepted | Partly | Yes | Passed (lists read with `size` 100) |
| A7 | `GET /v1/compute/instances/{id}` answers `data` as an array; an unknown id answers 404 | Partly | Yes | Passed: an absent id is reported as not found |
| A8 | `GET /v1/data-centers` and `GET /v1/compute/images` list regions and images | Yes | Yes | Passed |
| A9 | 429 and 5xx are provider errors; no write verb is ever sent | Yes (C19) | Yes (recorder) | Passed for the verbs (only GET and the token POST); 429 and 5xx not provoked |

Still open after the live run: the status code of a wrong password (A3), the token lifetime
and the renewal on a real expiry (A4), and the behaviour on 429 and 5xx. The status and size
text mapping is a design choice, not a provider fact.

### Live run of the Contabo adapter

On 2026-10-15 the Product Owner (S01) ran `pytest -m integration -k contabo -v` from `iac-node-forge-py` at `08439f3` against their real Contabo account, with the four credential values in their own shell: **9 passed, 288 deselected in 15.54 seconds**. The result was reported by S01 in chat; the output was not attached, and the number of instances in the account was not recorded.

| Test | Verdict |
| --- | --- |
| validate access with the credentials | Passed |
| validate access with a wrong API password returns a failed result | Passed |
| capabilities declare no write capability | Passed |
| server options `region` | Passed |
| server options `image` | Passed |
| list servers returns unmanaged servers (an empty account passes) | Passed |
| an absent server raises not-found | Passed |
| no credential value in any error | Passed |
| only GET requests and the token POST are issued | Passed |

What this confirms: the token exchange, the bearer use, the request identifier, the list endpoints with their pagination and the not-found path against the real service. It does not cover a wrong-password status code, a real token expiry, rate limiting, or an account with many instances.

## Effects on the use cases and ADRs

| Item | Effect |
| --- | --- |
| [UC-004] | Show the contract period (1, 12 or 24 months) in the cost confirmation for Contabo. |
| [UC-006] | On Contabo, tracking is polling the instance `status` and the action audit log. There is no task ID to follow. |
| [UC-009] | Warn that a Contabo rollback removes newer snapshots. |
| [UC-012] | Contabo cancellation has a `cancelDate`; confirm the exact rule before the wording is final. |
| [UC-014] | Contabo SSH keys and passwords are secrets referenced by ID. Proxmox VE keys go through cloud-init configuration. |
| [UC-015] | Resize on Contabo is unclear (C17). Proxmox VE resize is a configuration edit (P12). |
| [ADR-0002] | The capability model fits: task model, snapshot rules and removal semantics really differ. |
| [ADR-0003] | The four Contabo values are confirmed (C1). Token lifetime is open (C2). Proxmox token usage is open (P2). |

## Live run

On 2026-10-15 the Product Owner (S01) ran the eight integration tests of `iac-node-forge-py` (`pytest -m integration`, `PVE_VERIFY=false`) against a real Proxmox VE in the container `dockurr/proxmox:latest` on their own machine, with an API token of `root@pam` created by `pveum user token add root@pam iacnf --privsep 0`. All eight passed. The result was reported by S01 in chat; the output was not attached and the image digest and Proxmox VE version were not recorded.

| Test | Verdict |
| --- | --- |
| validate access with the token | Passed |
| validate access with a wrong token returns a failed result | Passed |
| capabilities declare no write capability | Passed |
| server options `node` lists at least one node | Passed |
| server options `storage` returns a tuple | Passed |
| list servers returns unmanaged servers | Passed |
| an absent server raises not-found | Passed |
| the token secret does not appear in an error | Passed |

What this confirms: the token header, `GET /version`, `/nodes`, `/nodes/{node}/storage` and `/cluster/resources?type=vm`, and the answer shapes the adapter parses. It does not cover a cluster with several nodes, a server that is running, or Proxmox VE versions other than the one in the container.

## Power actions (MIL-004)

Task 11 of [MIL-004]. The columns say what the provider documentation states, what the
in-process mock does (the power contract suite runs the same behaviours against the fake, the
Proxmox VE adapter and the Contabo adapter), and what a live run has shown. No live power run
has been made yet (task 13), so the live column is `Pending` throughout.

| # | Statement | Documentation | Mock | Live |
| --- | --- | --- | --- | --- |
| W1 | Proxmox VE: `POST .../status/start`, `shutdown`, `stop` and `reboot` answer a task identifier (UPID) | Yes (P3, P7) | Yes | Passed for `start`, `shutdown`, `stop` and `reboot` of a container (2026-10-18) |
| W2 | Proxmox VE: a task is followed through `.../tasks/{upid}/status` until `status` is `stopped`; `exitstatus` `OK` is success, anything else a failure | Yes (P4) | Yes | Passed: `OK` for all four of a container (2026-10-18) |
| W3 | Proxmox VE: the API token needs `VM.PowerMgmt` for the four requests | Yes (P13) | Not modelled | Pending |
| W4 | Proxmox VE: an exit status such as `WARNINGS: n` is treated as failed, with the text as the detail | Not stated | Assumed | Partly: a shutdown of a VM without a guest OS ended with exit status `TASK ERROR: VM quit/powerdown failed - got timeout`, shown as failed; `WARNINGS: n` not seen |
| W5 | Contabo: `POST /v1/compute/instances/{id}/actions/start`, `shutdown`, `stop` and `restart` accept the request with the bearer token and a request identifier | Yes (C10) | Yes | Pending |
| W6 | Contabo: there is no task; the instance `status` is polled until it equals the target (`running` after start, `stopped` after shutdown and stop) | Partly (C10) | Yes | Pending |
| W7 | Contabo: the status sequence between the request and the target, and how long it takes | Not stated | Assumed | Pending |
| W8 | Contabo: a restart cannot be told apart from no change, so it is reported as succeeded only when the status is `running` after the settle time, with the detail saying so | Not stated | Yes | Pending |
| W9 | Both: no write request other than the four power actions is ever sent | Not applicable | Yes (recorder answers 405) | Passed (the live tests record the writes) |
| W10 | Both: a time limit that passes ends the operation as `unknown`, and the request is not repeated | Design choice ([ADR-0006]) | Yes | Not provoked |

### Live run against Proxmox VE, 2026-10-16 (first attempt)

The AI ran the live power tests against the disposable Proxmox VE container from `tests/integration/docker-compose.proxmox.yml`, with a VM `9001` without disk or guest OS and software emulation (no KVM on the host), an API token for `root@pam` with privilege separation off, and `iac-node-forge-py` at `336854d`. The token was kept in the process environment and removed afterwards.

| Test | Verdict |
| --- | --- |
| hard stop (start, then stop, with the extra opt-in) | Passed, 281 s (the slow start and stop are the emulation) |
| cycle (already-running check, start, shutdown, restart) | Not passed: start and the already-running check were correct; `shutdown` ended failed because the VM has no guest OS to answer the ACPI request, and the cleanup that restores the original state then left the VM running; it was stopped by hand afterwards |

This is a limit of the test target, not a verdict on graceful shutdown or restart: neither could be shown, and Go criterion 8 (start, shutdown and restart) is **not met**. It needs a server with a guest OS that answers ACPI. The restore step of the tests should also fall back to a hard stop, when that is allowed, so a failed graceful shutdown cannot leave a server running.

### Live run against a Proxmox VE container, 2026-10-18

The AI repeated the run in the same Docker Proxmox VE, this time against an Alpine Linux container (`vmid` 9002, created from the `alpine-3.24-default` template) that answers a graceful shutdown, with `iac-node-forge-py` at `68309a1` (the restore fix included) and a token for `root@pam` that was removed afterwards. `pytest -m integration -k "power and proxmox" -v`: **2 passed, 621 deselected in 583.72 seconds**.

| Test | Verdict |
| --- | --- |
| cycle (already-running check, shutdown or start, restart, original state restored) | Passed |
| hard stop (with the extra opt-in) | Passed |

What this confirms: W1 and W2 for `start`, `shutdown`, `stop` and `reboot` of a container, with the task followed to exit status `OK`; W9 (only the four power requests are sent); W10 was not provoked. It does not cover a virtual machine with a guest OS, the `VM.PowerMgmt` permission error (W3, the token had all privileges), a `WARNINGS` exit status (W4) or any Contabo behaviour (W5 to W8, not run because a Contabo instance costs money).

What the live run must still settle: W4 (the real exit status text), W7 (the real status sequence and
timing at Contabo) and W3 (the permission error shape). The status and timing numbers in
[ADR-0006] (120 seconds, 2 seconds) are design defaults, not provider facts.

## Still open

- Contabo token lifetime (C2), snapshot limits (C13), cancel date rule (C14) and upgrade behaviour (C17).
- Proxmox VE snapshot-by-storage rules (P9).
- Anything about real behaviour (timing, error cases). That needs a Proxmox VE VM and read-only Contabo calls, as in [ADR-0001].

---

[MIL-001]: ./milestones/mil-001-use-case-baseline.md
[ADR-0001]: ./adr/adr-0001-provider-test-strategy.md
[ADR-0002]: ./adr/adr-0002-provider-capability-model.md
[ADR-0003]: ./adr/adr-0003-credential-storage.md
[ADR-0006]: ./adr/adr-0006-power-actions-and-operation-tracking.md
[MIL-004]: ./milestones/mil-004-power-control.md
[UC-004]: ./use-cases/uc-004/uc.md
[UC-006]: ./use-cases/uc-006/uc.md
[UC-009]: ./use-cases/uc-009/uc.md
[UC-012]: ./use-cases/uc-012/uc.md
[UC-014]: ./use-cases/uc-014/uc.md
[UC-015]: ./use-cases/uc-015/uc.md
