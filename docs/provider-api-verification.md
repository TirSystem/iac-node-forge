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
| P2 | API tokens exist | Partly | Token management paths `/access/users/{userid}/token/{tokenid}` exist. How a token is sent on a request is not in the API viewer. |
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

## Still open

- Contabo token lifetime (C2), snapshot limits (C13), cancel date rule (C14) and upgrade behaviour (C17).
- Proxmox VE token header and snapshot-by-storage rules (P2, P9).
- Anything about real behaviour (timing, error cases). That needs a Proxmox VE VM and read-only Contabo calls, as in [ADR-0001].

---

[MIL-001]: ./milestones/mil-001-use-case-baseline.md
[ADR-0001]: ./adr/adr-0001-provider-test-strategy.md
[ADR-0002]: ./adr/adr-0002-provider-capability-model.md
[ADR-0003]: ./adr/adr-0003-credential-storage.md
[UC-004]: ./uc-004/uc.md
[UC-006]: ./uc-006/uc.md
[UC-009]: ./uc-009/uc.md
[UC-012]: ./uc-012/uc.md
[UC-014]: ./uc-014/uc.md
[UC-015]: ./uc-015/uc.md
