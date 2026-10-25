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

## Provisioning (MIL-005)

Task 11 of [MIL-005]. The columns say what the provider documentation states, what the in-process
mock does (the provisioning contract suite runs the same behaviours against the fake, the Proxmox VE
adapter and the Contabo adapter), and what the live run of 2026-10-18 showed. Only Proxmox VE was run
live; no Contabo instance is created by a test, because it costs money and commits the account to a
contract period.

| # | Statement | Documentation | Mock | Live |
| --- | --- | --- | --- | --- |
| V1 | Proxmox VE: `POST /nodes/{node}/lxc` creates a container from a template and answers a task identifier | Yes (P3, P6) | Yes | Passed (a container with an Alpine template) |
| V2 | Proxmox VE: the new identifier is chosen by the caller, from `/cluster/nextid`; a taken identifier fails | Yes (P5) | Yes | Passed for the identifier from `nextid`; a taken one not provoked |
| V3 | Proxmox VE: the root disk is given as `<storage>:<size in GB>` on a directory storage | Not stated | Assumed | Passed (`local:1`) |
| V4 | Proxmox VE: templates are listed through the content of the storages (`vztmpl`, `iso`) | Partly (P5; the `content` filter of the storage list is not in the note) | Yes | Passed (the template was offered and the description validated) |
| V5 | Proxmox VE: creating needs `VM.Allocate`, and a 401 or 403 names it | Yes (P13) | Yes | Not provoked (the token had all privileges) |
| V6 | Proxmox VE: `POST /nodes/{node}/qemu` creates a virtual machine | Yes (P6) | Yes | Not run |
| V7 | Contabo: `POST /v1/compute/instances` with image, product, region and a period of 1, 12 or 24 months | Yes (C5, C6) | Yes | Not run (cost) |
| V8 | Contabo: the products to choose from are listed at `GET /v1/compute/products` | Not stated | Assumed (marked UNVERIFIED in the code) | Not run |
| V9 | Contabo: a new instance moves through `provisioning` and `installing` to `running`, or to `error` | Partly (C8 lists the values, not the order) | Assumed | Not run |
| V10 | Both: a timeout of the create request, or a 5xx at Contabo, may hide a created server, so the outcome is unknown and the intent stays pending | Design choice ([ADR-0007]) | Yes | Not provoked |
| V11 | Both: no write request other than the four power actions and the create requests is ever sent | Not applicable | Yes (recorder answers 405) | Passed (the live test counts the writes) |

### Live run against a Proxmox VE container, 2026-10-18

The AI ran `pytest -m integration -k provision -v` from `iac-node-forge-py` at `8df7390` (the merged
`main` has the same tests) against the Docker Proxmox VE of `tests/integration/docker-compose.proxmox.yml`,
with a token for `root@pam` that was removed afterwards and the template `alpine-3.24-default_20260714`:
**1 passed, 922 deselected in 1042.83 seconds (17 min 22 s)**. The Docker Proxmox VE runs under emulation, so
the creation and the clean-up are slow.

| Step of the test | Verdict |
| --- | --- |
| define a description (container, 128 MB, 1 core, 1 GB) and validate it against the offered options | Passed |
| preview: ready, no cost text, no request sent | Passed |
| request with confirmation, follow to the end, complete | Passed (`succeeded`, `completed`) |
| the server is recorded as managed and listed under the chosen name | Passed |
| a second request for the same name is refused and sends nothing | Passed (`name_exists`) |
| no credential value in a text or in the store file | Passed |
| the test-only clean-up deletes the container | Passed (the container list was empty afterwards) |

What this confirms: V1 to V4 and V11 for a container. What it does not cover: a virtual machine (V6), the
permission error (V5), a taken identifier on the real service (V2), the lost-answer path (V10) and every
Contabo statement (V7 to V9).

## Removal (MIL-006)

Task 11 of [MIL-006]. The columns say what the provider documentation states, what the in-process mock
does (the removal contract suite runs the same behaviours against the fake, the Proxmox VE adapter and the
Contabo adapter), and what the live run of 2026-10-18 showed. Only Proxmox VE was run live; no Contabo
instance is cancelled by a test, because a cancellation cannot be undone from here and the contract runs on.

| # | Statement | Documentation | Mock | Live |
| --- | --- | --- | --- | --- |
| R1 | Proxmox VE: `DELETE /nodes/{node}/lxc/{vmid}` with `purge` and `destroy-unreferenced-disks` answers a task identifier | Yes (P3, P10) | Yes | Passed (a container) |
| R2 | Proxmox VE: after the task the guest and its disks are gone, and the server is no longer listed | Yes (P10) | Yes | Passed (the adapter no longer lists it and reports it as not found) |
| R3 | Proxmox VE: deleting a running guest is refused by the provider | Not stated | Assumed (500) | Not run: the product refuses a running server before any request |
| R4 | Proxmox VE: the delete needs `VM.Allocate`, and a 401 or 403 names it | Yes (P13) | Yes | Not provoked (the token had all privileges) |
| R5 | Contabo: `POST /v1/compute/instances/{id}/cancel` sets the status `cancelled` and a `cancelDate` | Partly (C14) | Assumed (the shape of the answer) | Not run |
| R6 | Contabo: the rule for the cancel date (for example the end of the period) | Not stated | Assumed | Not run; the product shows and records the date the provider reports, or says that none was reported |
| R7 | Both: a timeout of the removal request, or a 5xx at Contabo, may hide a removal, so the outcome is unknown and the request is not repeated | Design choice ([ADR-0008]) | Yes | Not provoked |
| R8 | Both: no write request other than the four power actions, the creations and the two removals is ever sent | Not applicable | Yes (recorder answers 405) | Passed (the live test saw exactly one POST and one DELETE) |
| R9 | Proxmox VE: a freed identifier can be reused, so the managed record is keyed by its recording time too | Not stated | Unit tests | Not provoked |

### Live run against a Proxmox VE container, 2026-10-18

The AI ran `pytest -m integration -k provision -v` from `iac-node-forge-py` at `f081b2c` (the merged `main` has
the same tests) against the Docker Proxmox VE of `tests/integration/docker-compose.proxmox.yml`, with a token for
`root@pam` that was removed afterwards and the template `alpine-3.24-default_20260714`: **1 passed, 1163
deselected in 1183.41 seconds (19 min 43 s)**. The test now creates the container through the product and then
removes it through the product; the test-only delete helper of MIL-005 no longer exists.

| Step of the test | Verdict |
| --- | --- |
| create the container through the product, recorded as managed | Passed (as in the run of MIL-005) |
| removal preview: ready, stopped, managed, the consequence says the server and its disks are destroyed now | Passed |
| a wrong typed identifier and a missing confirmation send nothing | Passed |
| confirmed request, followed to the end, completed | Passed (`succeeded`, `completed`) |
| the consequence is recorded with the operation and the managed record is ended | Passed |
| the container is no longer listed, and a second request reports not found and sends nothing | Passed |
| exactly one POST and one DELETE were sent in all | Passed |
| no credential value in a text or in the store file | Passed |

What this confirms: R1, R2 and R8 for a container. What it does not cover: a virtual machine, a running guest
(R3), the permission error (R4), the lost-answer path (R7), the identifier reuse (R9) and every Contabo
statement (R5 and R6).

## File transfer (MIL-007)

Task 10 of [MIL-007]. This slice does not use the provider API: it reaches the server itself over SSH
([ADR-0009]). The columns say what the design assumes, what the in-process fake does (the transfer contract
suite runs the same behaviours against the fake and against the OpenSSH adapters), and what the live run of
2026-10-20 showed. The live server was a throw-away OpenSSH 9.9 server with BusyBox 1.37 in an Alpine container
on the same machine, reached with a key pair generated for the run, a temporary `known_hosts` and an empty
`ssh_config`; the real `~/.ssh` was not read or changed (its files kept their modification times). Two clients
were tried: the OpenSSH of Git for Windows (10.2) and the Windows-native OpenSSH (9.5).

| # | Statement | Design | Fake | Live |
| --- | --- | --- | --- | --- |
| T1 | The system `ssh` started as a process honours a key file given by hint, the user's config and `known_hosts`, with `BatchMode` and `StrictHostKeyChecking=yes` | ADR-0004, ADR-0009 | Not applicable | Passed (both clients; the test used a temporary config and `known_hosts`) |
| T2 | A tar stream over `ssh` copies a tree in both directions, including a nested folder, an empty file, a non-ASCII name and a relative link | ADR-0009 | Yes | Passed (BusyBox `tar`) |
| T3 | The manifest is built with `find`, `sha256sum`, `stat` and `readlink`, and a changed byte shows as a difference | ADR-0009 | Yes | Passed on BusyBox; a GNU userland was checked by hand only |
| T4 | `du -sk` gives the size for the room check | ADR-0009 | Yes | Passed on BusyBox |
| T5 | `tar --no-same-owner` is probed on an empty archive to see whether the remote `tar` accepts it | ADR-0009 | Yes | Passed on BusyBox |
| T6 | An unknown host key stops the transfer and shows its fingerprint; the same fingerprint accepts it; a changed key stops it and is never accepted, not even with the fingerprint | ADR-0004, ADR-0009 | Yes | Passed |
| T7 | A restore adds and overwrites and never deletes: files already on the server stay and are reported | ADR-0009 revision 2 | Yes | Passed (found by this run; the first rule failed such a restore) |
| T8 | The OpenSSH 9.9 server bans a client that runs `ssh-keyscan` many times in a short while | Not foreseen | Not applicable | Observed: the throw-away server sets `PerSourcePenalties no`; how a real server rate-limits repeated key scans is not known |
| T9 | The Windows-native OpenSSH 9.5 client cannot negotiate the post-quantum key exchange a 9.9 server offers first | Not foreseen | Not applicable | Observed: the throw-away server restricts `KexAlgorithms`; a real server with an old client can behave the same |
| T10 | A password or key passphrase prompt, a password-only server, the Windows ssh-agent service and a user without the right to create links | ADR-0009 | Not applicable | Not run |

What the live run confirms: T1 to T7 on one server type. It does not cover a GNU userland server, a server that
needs a password or a passphrase, `ProxyJump`, a long transfer (the four-hour stream time limit is untested), or
any Linux or macOS client.

## Backup and restore (MIL-008)

Task 1 of [MIL-008]. The columns say what the provider documentation states (with the earlier statement
numbers where one applies), what the in-process mock does and what a live run showed. The mocks and the live
run come in later tasks, so those columns say `Pending`, or `Not applicable` where the statement is about what
a provider does not offer. Verdicts in the Documentation column use the words of the table at the top: Verified,
Partly, Not stated, Differs.

**Sources and how they were read.** Proxmox VE: the API viewer schema `apidoc.js` (449 paths, read on
2026-10-25: parameters, return types, permissions), and the administration guide pages `chapter-vzdump`,
`chapter-pvesm`, `chapter-pct`, `pct.1` and `qmrestore.1` at `pve.proxmox.com/pve-docs`, read through a page
reader that summarises (so the wording is a paraphrase). The `pct` and `qm` chapters did not yield the
overwrite rules; for a running guest one web search found only a 2020 developer-list patch, which is not
documentation. Contabo: the OpenAPI 3.0.3 spec embedded in `https://api.contabo.com/` (read 2026-10-25),
snapshot, product, instance and upgrade paths and schemas, searched for limits and for asynchronous wording.
The Docker Proxmox VE could not be started: no `/dev/kvm` (`docker run --rm --privileged alpine ls /dev/kvm`
failed once; not retried), so no Live column was read there.

### Proxmox VE

| # | Statement | Documentation | Mock | Live |
| --- | --- | --- | --- | --- |
| B1 | `POST /nodes/{node}/vzdump` creates a backup and answers a string, the task identifier (UPID), followed as in P4 | Verified (P3) | Yes | Passed (the dump task was followed to its end) |
| B2 | Parameters: `vmid` (the guest), `storage` (where the file goes), `mode` (`snapshot` default, `suspend`, `stop`), `compress` (`0` default, `1`, `gzip`, `lzo`, `zstd`), `notes-template` (variables `{{cluster}}`, `{{guestname}}`, `{{node}}`, `{{vmid}}`), `protected`, `remove` (default true: prune older backups per `prune-backups`), `prune-backups` | Verified | Yes | Passed for `vmid`, `storage`, `mode` snapshot, `remove` 0 and `notes-template` |
| B3 | `remove` prunes only by the retention rule, and the default `prune-backups` is `keep-all=1` (nothing is deleted); a storage can carry its own retention | Partly (the guide gives the default for jobs; the storage-level value is read from the storage configuration, which needs `Datastore.Allocate`) | Not applicable | Not run (the dump sends `remove` 0) |
| B4 | A running guest can be backed up: `snapshot` mode copies while it runs (a container is briefly suspended for the snapshot), `suspend` suspends it, `stop` shuts it down and starts it again | Verified | Not applicable | Not run (the container was stopped) |
| B5 | A storage declares what it holds with its `content` list; `backup` is the content type for vzdump files, stored in the `dump/` folder of a directory storage; the default `local` storage (`/var/lib/vz`) is documented as `iso,vztmpl,backup` | Verified (guide); the install on a given host can have changed it, so the product must check | Yes | Passed (the `local` storage of the Docker Proxmox VE has `rootdir,backup,vztmpl,snippets,images,iso`) |
| B6 | `GET /nodes/{node}/storage?content=backup` lists the storages that accept backups, and each storage entry carries its `content` list | Verified (P5) | Yes | Passed (the storage filter listed `local`) |
| B7 | The produced archive is found again with `GET /nodes/{node}/storage/{storage}/content?content=backup&vmid=N`; each item has `volid`, `format`, `ctime`, `size`, `vmid`, `notes` (first line), `protected`, `verification` (Proxmox Backup Server only) | Verified | Yes | Passed (the archive was found again by listing the storage for the vmid) |
| B8 | The `volid` has the form `storage:backup/<file>`; the file name encodes the guest type, the id and the time, for example `vzdump-lxc-105-2009_10_09-11_04_43.tar` with the extension `.zst`, `.gz`/`.tgz` or `.lzo` for the compression | Partly (the guide's own example has no `.zst`; the `storage:backup/` prefix is the volume identifier form, not spelled out in the guide) | Yes | Passed (the volume id was used for the restore and for the delete) |
| B9 | The backup task's identifier does not name the archive; the archive is picked by listing and taking the newest `ctime` for the vmid (or by matching the `notes`) | Not stated (an inference from B1 and B7) | Yes | Passed (matched by the marker in the notes) |
| B10 | A container is restored with `POST /nodes/{node}/lxc` and a virtual machine with `POST /nodes/{node}/qemu`; `archive` (a volume identifier or a path) selects the backup, `vmid` the target, `storage` the target storage, `unique` a new MAC address, `start` starts it after; both answer a UPID. For a container the schema names `ostemplate` ("the OS template or backup file") together with `restore=1` | Verified (P6); `lxc` takes `ostemplate` with `restore`, not `archive` | Yes | Passed for a container (`ostemplate` with `restore`); a virtual machine was not run |
| B11 | `force` ("allow to overwrite existing" guest) lets a restore replace a guest that already has the vmid; without it a restore onto an existing vmid is refused | Partly (`force` is documented; the refusal without it is not worded in the schema) | Yes | Passed with `force` over an existing container; the refusal without `force` was not provoked |
| B12 | A restore over an existing guest needs that guest to be stopped | Not stated in the documentation (only a 2020 developer-list patch implies a running container aborts); the product must refuse or stop first and a live run must settle it | Yes | Settled for a container: refused with HTTP 500 and the text `can't overwrite running container`; a virtual machine was not run |
| B13 | What `force` overwrites: the guest is replaced by the archive's configuration and disks; the guest's own disks and settings that are not in the archive are not documented as kept | Not stated | Yes | Partly: a description changed after the backup came back to the archive's value, so the configuration is replaced; the content of the disk and any setting that is not in the archive were not examined |
| B14 | Permissions. Dump: `VM.Backup` on the guest and `Datastore.AllocateSpace` on the backup storage (`Datastore.Allocate` for `prune-backups`; `root@pam` only for `tmpdir`, `dumpdir`, `script`, `job-id`). Restore: `VM.Allocate` on the guest, or only `VM.Backup` when the guest already exists, and `Datastore.AllocateSpace` on the storage; a privileged container also needs `Sys.Modify` on `/`. Listing the archives: `Datastore.Audit` or `Datastore.AllocateSpace` | Verified (P13) | Yes | Not provoked (the token had all privileges) |
| B15 | No call downloads a backup file to the local machine: `download-url` (the server fetches a URL) and `upload` (the client sends a file) accept only the contents `iso`, `vztmpl` and `import`, not `backup`; the only `download` path is `file-restore/download`, which extracts a file or folder as a zip from a Proxmox Backup Server backup | Verified (absence in the schema; the UC-018 note holds) | Not applicable | Not applicable |
| B16 | Deleting a backup is `DELETE /nodes/{node}/storage/{storage}/content/{volume}`, answering a task identifier or nothing; it needs `Datastore.Allocate`, or `Datastore.AllocateSpace` plus `VM.Backup` for a backup volume. A `protected` backup is not removed by pruning. Out of scope for MIL-008 | Verified | Yes | Passed (a test-only delete of the archive the run made) |

### Contabo

| # | Statement | Documentation | Mock | Live |
| --- | --- | --- | --- | --- |
| B17 | Snapshots: `POST /v1/compute/instances/{instanceId}/snapshots` (body `name` required, 1 to 30 characters, letters, numbers, spaces and dashes; `description`, 1 to 255) answers 201 and `data`, an array holding the snapshot (`snapshotId`, `name`, `description`, `instanceId`, `createdDate`, `autoDeleteDate`, `imageId`, `imageName`); `GET` lists them (paginated), `GET .../{snapshotId}` reads one, `PATCH` renames, `DELETE` answers 204 | Verified (C11) | Yes (the shape of the answer is assumed) | Not applicable (no snapshot is created by a test: cost) |
| B18 | `POST .../snapshots/{snapshotId}/rollback` (empty body) answers 200 and the snapshot; rolling back to a snapshot that is not the latest deletes all newer snapshots of the instance | Verified (C12) | Yes (the shape of the answer is assumed) | Not applicable (a rollback deletes newer snapshots) |
| B19 | A snapshot has an `autoDeleteDate`, so the provider deletes it by itself on that date; the rule for the date (a fixed number of days) is not stated | Partly (the field and example show about a month after creation; no rule) | Yes (the shape of the answer is assumed) | Not applicable |
| B20 | Whether create and rollback are asynchronous, and how their end is seen: there is no task resource (C7), no snapshot status, and no instance status for snapshotting or restoring. The listed statuses (C8) include `running`, `stopped`, `installing`, `error` but the spec does not say which one a snapshot or rollback passes through | Not stated | Yes (the shape of the answer is assumed) | Not applicable |
| B21 | The number of snapshots allowed: no limit in the snapshot paths. The product list gives each product a `snapshots` count ("number of snapshots included in the product", example 0), so a limit exists per product and a plan can include none; what happens at the limit (an error, or paid snapshots) and the price are not stated | Partly (C13 now: limit per product, value read from the product, behaviour at the limit not stated) | Yes (the shape of the answer is assumed) | Not applicable |
| B22 | There is no real backup interface: no path for backup, export, download or copy of a snapshot or an image; images can only be provided by URL (`POST /v1/compute/images`). The one backup feature is a paid "automated backup" add-on (`POST .../upgrade` with `backup: {}`, price `backupPrice`, flags `backupAvailable` and `hasBackupAddon`), and no path lists, restores or downloads what it keeps | Verified (absence in the spec); Differs from the UC-018 note "no backup API" only in that the add-on exists, purchasable but not usable through the API; C17 notes the upgrade description names only firewall and private network | Not applicable | Not applicable |
| B23 | The snapshot audit (`GET /v1/compute/snapshots/audits`) lists the snapshot actions triggered through the API | Verified (C9) | Yes (the shape of the answer is assumed) | Not applicable |

### What the product can claim

| # | Statement | Basis | Mock | Live |
| --- | --- | --- | --- | --- |
| B24 | Neither provider documents copying a backup to the local PC (Proxmox VE has no download of a vzdump file; Contabo has no download of a snapshot), so the product claims no such copy | B15, B22 | Not applicable | Not applicable |
| B25 | A backup is at Proxmox VE a file on a storage with `backup` content (on the same host unless the storage is remote), and at Contabo a snapshot held by the provider, which the provider may delete on `autoDeleteDate`; neither is off-site by itself | B5, B19 | Not applicable | Not applicable |
| B26 | A restore at Proxmox VE replaces the guest with the same id (configuration and disks, `force`); at Contabo it reverts the instance's disk to the snapshot and deletes every newer snapshot | B11, B13, B18 | Yes | Settled for a container (see B12 and B13); a virtual machine was not run |
| B27 | Cost and retention: at Proxmox VE the storage space; the default retention keeps everything. At Contabo a snapshot may count against the product's included number, and the price per extra snapshot is not stated, so the product states "cost not stated" instead of a figure | B3, B21 | Not applicable | Not applicable |

What this changes for the design: the plan holds for Contabo. For Proxmox VE the plan needs three checks it
did not name: the target storage must declare `backup` content (B5, B6), the archive is found by listing and
not by the task (B9), and a running guest may have to be stopped before a restore (B12). The
overwrite rule (B11, B13) and the running-guest rule are not in the documentation and are what the live run of
task 13 has to settle. No statement contradicts the milestone, apart from the add-on in B22.

### Live run against a Proxmox VE container, 2026-10-25

The AI ran `pytest -m integration -k "provision or full_backup" -v -s` with the experiment switched on, from
`iac-node-forge-py` at `6176c70` (the same tests as the merged `main`), against the Docker Proxmox VE of
`tests/integration/docker-compose.proxmox.yml` with a token for `root@pam` that was removed afterwards and the
template `alpine-3.24-default_20260714`: **2 passed, 2028 deselected in 3850.72 seconds (1 h 4 min)**. The Docker
Proxmox VE runs under emulation, so the dumps, restores and clean-up are slow. Afterwards the container list and the
dump folder were empty.

| Step of the whole-server test | Verdict |
| --- | --- |
| create a container through the product | Passed |
| backup preview: ready, names the storage, sends nothing; a request without confirmation sends nothing | Passed |
| confirmed backup followed to its end, the archive found again, recorded, listed as made by the client | Passed |
| the container description changed by one documented test-only write, read back | Passed |
| restore preview states the overwrite; a wrong typed identifier and a missing confirmation send nothing | Passed |
| confirmed restore followed and completed, state of the server reported, consequence recorded | Passed |
| the description is back to its value from before the backup | Passed |
| removal through the product and test-only delete of the archive | Passed |
| experiment: the product refuses a restore of a running container before any request | `running_refused` |
| experiment: a restore sent directly over the running container | HTTP 500, `can't overwrite running container` |

What this confirms: B1, B2 and B5 to B12 for a container, and B13 in part (the configuration is replaced). It does
not cover a virtual machine, a backup of a running guest (B4), the permission error (B14), the refusal without
`force`, what a restore does to the content of the disk, or anything at Contabo.

## Still open

- Contabo token lifetime (C2), cancel date rule (C14) and upgrade behaviour (C17). Snapshot limits (C13) are
  now partly answered (B21): a count per product, behaviour at the limit still not stated.
- Backup and restore (MIL-008): restore over a running guest and what `force` overwrites (B12, B13), the archive
  name and volume form (B8), the snapshot and rollback completion at Contabo (B20), the `autoDeleteDate` rule (B19).
- Proxmox VE snapshot-by-storage rules (P9).
- Anything about real behaviour (timing, error cases). That needs a Proxmox VE VM and read-only Contabo calls, as in [ADR-0001].

---

[MIL-001]: ./milestones/mil-001-use-case-baseline.md
[ADR-0001]: ./adr/adr-0001-provider-test-strategy.md
[ADR-0002]: ./adr/adr-0002-provider-capability-model.md
[ADR-0003]: ./adr/adr-0003-credential-storage.md
[ADR-0006]: ./adr/adr-0006-power-actions-and-operation-tracking.md
[MIL-004]: ./milestones/mil-004-power-control.md
[MIL-005]: ./milestones/mil-005-provisioning.md
[MIL-006]: ./milestones/mil-006-delete-or-cancel.md
[MIL-007]: ./milestones/mil-007-file-backup-and-restore.md
[MIL-008]: ./milestones/mil-008-whole-server-backup-and-restore.md
[ADR-0009]: ./adr/adr-0009-server-access-and-file-transfer.md
[ADR-0008]: ./adr/adr-0008-removal-of-a-server.md
[ADR-0007]: ./adr/adr-0007-desired-configuration-and-provisioning.md
[UC-004]: ./use-cases/uc-004/uc.md
[UC-006]: ./use-cases/uc-006/uc.md
[UC-009]: ./use-cases/uc-009/uc.md
[UC-012]: ./use-cases/uc-012/uc.md
[UC-014]: ./use-cases/uc-014/uc.md
[UC-015]: ./use-cases/uc-015/uc.md
