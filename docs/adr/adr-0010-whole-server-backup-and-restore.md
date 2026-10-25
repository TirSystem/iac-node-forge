# Whole-server backup and restore

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0010 |
| CrossReference | [BC-001], [MIL-008], [ADR-0002], [ADR-0005], [ADR-0006], [ADR-0007], [ADR-0008], [ADR-0009], [UC-006], [UC-009], [UC-016], [UC-018], [UC-019] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-25 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-111 | [9fd15f2] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

A backup of a whole server and its restore ([UC-018], [UC-019]) are the last agreed core actions, and the
two providers mean different things by them. The verification note (statements B1 to B27) shows how:

- **Proxmox VE** has a native backup. `POST /nodes/{node}/vzdump` writes an archive of a guest to a
  storage and answers a task (B1). The archive is a volume on a storage whose `content` list holds
  `backup` (B5, B6). The task identifier does not name the archive: it is found again by listing
  `content?content=backup&vmid=N` (B7, B9). A restore is the creation request again (`POST .../lxc` with
  `ostemplate` and `restore=1`, `POST .../qemu` with `archive`), and `force` lets it replace a guest that
  exists (B10, B11). The documentation does not say whether a running guest may be replaced (B12) or what
  `force` overwrites (B13). Pruning by `remove` follows the retention rule, default keep everything, but a
  storage can carry its own (B2, B3).
- **Contabo** has no backup interface (B22). The nearest thing is a snapshot (B17); a rollback reverts the
  instance and deletes every newer snapshot (B18). A snapshot has an `autoDeleteDate` (B19), counts against a
  number included in the product, and its price at the limit is not stated (B21). Create and rollback have no
  task and no status, so their end cannot be observed directly (B20). A paid "automated backup" add-on exists
  but cannot be listed, restored or downloaded through the API (B22).
- Neither provider documents copying a backup to the local PC (B15, B22, B24), and neither backup is off-site
  by itself (B25).

A restore is the second action of the product that cannot be undone ([ADR-0008]): at Proxmox VE the guest, its
disks and its configuration are replaced; at Contabo the newer snapshots are lost. The user stories ask that a
backup is followed to completion and "where it is kept" is told, that a provider that cannot do it is shown as
unsupported, that a restore says what it will replace and must be confirmed, and that the state afterwards is
reported and recorded (US-001.11, US-001.12). The existing ports are read-only ([ADR-0002]), four power actions
([ADR-0006]), creation ([ADR-0007]) and removal ([ADR-0008]).

Options considered for the capability and the port:

1. **Add backup and restore to `ServerPowerPort` or `ServerProvisionPort`.** Fewer types, but a restore, a
   replace of a live guest, becomes reachable wherever a power action is, and the list of write requests loses
   its meaning.
2. **A separate narrow `ServerBackupPort`** implemented by both adapters, with the capabilities
   `backup_server` and `restore_server`. The write surface is a few named requests behind two capabilities;
   read-only, power, creation and removal code cannot reach it by type, and listing sits beside the backup
   because both need the provider's own list.
3. **Two ports, one for backup and one for restore.** The destructive part is separate by type, but the two
   need the same listing and the same location of a backup, and every adapter would implement both anyway.

Options considered for what a backup is:

1. **One word "backup" with no kind.** Simple, and exactly what makes a Contabo snapshot look like an
   independent copy, which it is not (same disk system, B25).
2. **A stated kind:** `ARCHIVE` (a file on a storage; Proxmox VE) and `SNAPSHOT` (held by the provider;
   Contabo), shown in every preview, list and result.
3. **Report Contabo as unsupported** because it has no backup API. Honest about the API, but it refuses the one
   useful thing the provider offers and makes the capability model say less than the provider does.

Options considered for finding a backup again:

1. **Trust the task identifier.** Not possible: it does not name the archive (B9).
2. **List the provider and pick the newest `ctime` at or after the start of the operation for the guest, and
   check the product's marker.** The provider is the authority; the marker is a second check that guards against
   a backup made at the same moment by someone else.
3. **Only the local record.** It cannot show backups made by other tools, and it goes stale when the provider
   deletes one.

Options considered for a restore at Proxmox VE:

1. **Restore into a new guest.** Safe for the existing guest, but it needs a free identifier, a node and a
   storage choice and starts a creation flow of its own; it is a different use case.
2. **Restore into the same guest identifier with `force`,** and refuse a running target.
3. **Stop a running guest on the user's behalf and then restore.** Convenient, but it adds a power request
   nobody asked for to a destructive action ([ADR-0008] refused the same).

Options considered for the commands: reuse `server backup` and `server restore` (taken by the file backup of
[ADR-0009], [UC-016]), or give the provider-level actions names that cannot be confused with them.

## Decision

Backup and restore are a separate `ServerBackupPort`, implemented by the Proxmox VE and Contabo adapters, with
the capabilities `backup_server` and `restore_server` (listing belongs to `backup_server`) and two backup kinds,
`ARCHIVE` and `SNAPSHOT`; a restore follows the protection of a removal (the identifier always typed, one more
confirmation for an unmanaged server, the consequence stated first and recorded), a running Proxmox VE target is
refused and never stopped for the user, and the write surface grows by exactly the dump, the restore and the
Contabo snapshot and rollback requests.

### Rules

- **Port and capabilities:** `ServerBackupPort`, beside `ProviderPort`, `ServerPowerPort`,
  `ServerProvisionPort` and `ServerRemovalPort`. A provider that does not declare `backup_server` or
  `restore_server` is reported as unsupported before any request. The port states its `BackupKind`
  (`backupKind`), lists the storages that accept backups (`backupStorages`), says whether a backup or a restore
  can be made now (`backupBlock`, `restoreBlock`, values of `BackupBlock`), gives the consequence of a
  backup (`backupConsequence`) and the effect of a restore (`restoreEffect`, a `RestoreEffect` that holds the
  consequence text and the backups the restore would delete),
  sends the one backup request (`requestBackup`) or the one restore request (`requestRestore`), lists the
  backups of a server (`listBackups`), finds the backup an operation made (`findBackup`) and reads the state
  of its operation (`operationState`).
- **Operations:** a backup and a restore are an `Operation` like a power action, with the new action values
  `BACKUP` and `RESTORE`. The type keeps the name `PowerAction`, as it did for `PROVISION` and `REMOVE`
  ([ADR-0007], [ADR-0008]); the state rules of [ADR-0006] apply and the operation is followed like any other
  ([UC-006]), through the backup port for these two actions. `ControlServerPower` refuses `BACKUP` and
  `RESTORE`; `ProvisionServer` and `RemoveServer` are not affected. The consequence text of both actions is
  recorded in `Operation.consequence`, as it is for a removal.
- **Backup kinds:**
  - `ARCHIVE` (Proxmox VE): `POST /nodes/{node}/vzdump` with `vmid`, `storage`, `mode=snapshot`,
    `remove=0` and a `notes-template` that holds the marker `iac-node-forge <operation identifier>`. The
    product sends `remove=0` so that the dump never prunes older backups by a retention rule of the storage
    (B2, B3): the product deletes nothing. Compression is not requested (the default is none, B2); it is left
    to a later change. The task is polled as in P4 until `stopped`; `OK` is `succeeded`, any other exit status
    is `failed`. The archive is found by listing `content?content=backup&vmid=N` on the storage, taking the
    newest `ctime` at or after the start of the operation whose `notes` begin with the marker (B7, B9). If no
    archive matches after a successful task, the operation is `succeeded` but the result says that the
    backup could not be located, and nothing is recorded as a backup.
  - `SNAPSHOT` (Contabo): `POST /v1/compute/instances/{id}/snapshots` with the name
    `iacnf-<UTC yyyymmddHHMM>` (18 characters, within the limit of 30, B17) and a description
    `Created by iac-node-forge, operation <operation identifier>` (within 255). The answer holds the snapshot,
    whose `snapshotId` is the backup identifier. There is no task and no snapshot status (B20): the operation
    is followed by reading the instance and re-listing the snapshots until the new one is listed and the
    instance status is `running` or `stopped` (not `installing` or `error`); a status that is not final or a
    passed time limit ends the operation as `unknown`, never as success.
  - **What Contabo offers is said plainly:** the provider documents no backup interface (B22). A `SNAPSHOT` is
    kept by the provider on the same disk system as the instance, counts against the number of snapshots the
    product includes, its price at the limit is not stated (B21) and the provider deletes it on its
    `autoDeleteDate` (B19). The preview and the result say "snapshot, not an independent backup" and "cost not
    stated"; they name the paid automated-backup add-on as existing but not usable through this product.
- **Where it is kept:** the result tells the location: for `ARCHIVE` the storage and the volume (`volid`, for
  example `local:backup/vzdump-lxc-105-...`), for `SNAPSHOT` the snapshot name and, when the provider reports
  it, its auto-delete date. A backup identifier is provider-specific text (the `volid` or the `snapshotId`);
  every list and result also shows a short local alias, the first eight hexadecimal characters of the SHA-256
  of the identifier. A command accepts the identifier or the alias if it is unique among the backups of that
  server.
- **Storage (Proxmox VE):** the dump storage must declare the content type `backup` (B5, B6). It is checked from
  the storage's content list before anything is sent. With `--storage S`, a storage that does not exist or does
  not hold `backup` is refused with the reason. Without `--storage`, the only storage that holds `backup` is
  used; if there are several they are listed and the user chooses (`STORAGE_REQUIRED`); if there is none the
  backup is refused (`NO_BACKUP_STORAGE`). Contabo has no storage; `--storage` there is refused.
- **Restore at Proxmox VE:** only back into the same guest identifier, with `force`. No new guest is created in
  this milestone. A container is restored with `POST /nodes/{node}/lxc` with `vmid`, `ostemplate` set to the
  `volid`, `restore=1` and `force=1`; a virtual machine with `POST /nodes/{node}/qemu` with `vmid`,
  `archive` set to the `volid` and `force=1` (B10, B11). The backup must be of the same guest type as the guest
  (the type is read from the guest and from the volume name, B8); otherwise the restore is refused
  (`BACKUP_MISMATCH`). The product does not send `start`, `unique` or `storage`; the state of the guest after
  the restore is read and reported. Which storage the restored disks use when none is given, and whether the
  restore keeps disks that the archive does not hold, are not documented (B13) and are settled by the live run
  of task 13.
- **Running target (Proxmox VE):** refused before any request, with the instruction to shut it down first
  (`ControlServerPower`). B12 is not documented; the product does not rely on a running guest being replaced
  and never stops it for the user. This rule can be relaxed only by a later decision after a live run shows what
  happens.
- **Consequence text at Proxmox VE:** "Guest N (name) on node X is overwritten by the backup `<volid>` made at
  `<time>`: its disks and its configuration are replaced by the content of the archive. What `force` leaves
  untouched is not documented. This cannot be undone." It is shown before the confirmation and recorded.
- **Restore at Contabo:** a snapshot rollback, `POST .../snapshots/{snapshotId}/rollback` with an empty body
  (B18). Before the request the preview lists the snapshots that are newer than the chosen one (read from the
  provider's list, by name and date) and states that the rollback deletes them, that the instance returns to the
  state of the chosen snapshot and that the cost is not stated (B21, B27). `RestoreEffect` holds that
  list of deleted backups; it is empty for `ARCHIVE`. Completion cannot be observed directly (B20): `operationState` re-reads the
  instance status and re-lists the snapshots, and the operation is `succeeded` only when the instance is
  `running` or `stopped` and none of the newer snapshots is listed; while they remain, or the status is not
  final, it is `running`, and when the time limit passes it ends as `unknown`.
- **Protection of a restore** (the rules of [ADR-0008], applied unchanged):
  - The server identifier is always typed: interactively it is retyped at the prompt; in a non-interactive run
    `--yes` is required and the identifier argument is the typed identifier. It must equal the provider's
    identifier exactly; nothing is sent otherwise.
  - A server not managed by this client needs one more confirmation, the identifier typed again;
    non-interactively `--confirm-unmanaged <identifier>` as well as `--yes`.
  - The consequence is stated first and recorded with the operation.
  - A running Proxmox VE target is refused. A restore has no "already in that state" case: a Contabo instance
    that is `cancelled` is refused as unavailable (`NOT_AVAILABLE`).
  - Without a valid confirmation nothing is sent and nothing is recorded.
- **Protection of a backup:** a plain confirmation (`--yes` or an interactive yes), because it costs space and
  time but changes no existing data. The preview states where the backup goes and, if known, how much space
  the guest uses. A server not managed by this client needs no extra confirmation for a backup. Without
  confirmation nothing is sent.
- **Listing:** `listBackups` reads the provider, which is authoritative, and marks a backup as the product's
  when its `notes` begin with the marker (Proxmox VE) or its name begins with `iacnf-` (Contabo). It merges the
  local `BackupRecord` by backup identifier for the operation that made it. A record whose backup the provider
  no longer lists is reported as gone from the provider, not deleted. A backup that the product did not make can
  be listed and restored; it is marked as not the product's.
- **Records:** `BackupRecord(configuration_id, server_identifier, backup_id, kind, location, created_at,
  operation_id)`, kept in the local JSON Lines file as the record type `backup`, with the key
  (configuration_id, server_identifier, backup_id), written when a backup operation has `succeeded` and the
  backup was located. It never holds a secret: no token, no key, no credential value. `Operation.consequence`
  (bounded to 500 characters) already exists. After a restore the state of the server that was read is recorded
  in the `detail` of the operation, not in a new record.
- **No duplicate-protection record:** a repeated backup makes another backup (it is not a billing event, but it
  uses space), and a repeated restore meets the new state. A timeout or a lost answer ends the operation as
  `unknown` and the request is not repeated.
- **Commands.** The file backup keeps `server backup` and `server restore` ([ADR-0009]); the provider-level
  actions are:
  - `server full-backup <configuration> <server-identifier> [--storage S] [--yes] [--no-wait] [--timeout T]`
  - `server full-backups <configuration> <server-identifier>`
  - `server full-restore <configuration> <server-identifier> <backup-id> [--yes] [--confirm-unmanaged ID]
    [--no-wait] [--timeout T]`

  The three words are different commands from `backup`, `restore`, `access`, `define`, `provision`,
  `definitions` and `remove`, and none is a prefix of another; a test shows that each command reaches its own use
  case. They use the exit codes of the existing commands.
- **Write allow-list:** the four power POSTs, the Proxmox VE `lxc` and `qemu` creations, the Contabo instance
  creation and its token POST, the Proxmox VE `DELETE` of an `lxc` or `qemu` resource, the Contabo `cancel`
  POST, and now the Proxmox VE `vzdump` POST, the Proxmox VE `lxc` and `qemu` restores, and the Contabo
  snapshot POST and rollback POST. Nothing else: no snapshot deletion, no backup deletion, no reinstall, rescue,
  resize or clone. A restore uses the same paths as a creation, so the recorder tells them apart by the body: a
  POST to `.../lxc` or `.../qemu` is a **creation** only when its body has none of `force`, `restore` and
  `archive`, and a **restore** only when it has `force=1` and, for `lxc`, `restore=1` with `ostemplate`, for
  `qemu`, `archive`. Any other combination is not on the list and a test fails. The recorder classifies every
  write by its method, path pattern and this body rule, and the test lists the classes the mocks received.
- **No secret:** the consequence, the operation record, the backup record and every error text never hold a
  credential, a token or a key value; an error for a 401 or 403 names the permission (`VM.Backup`,
  `Datastore.AllocateSpace`, `VM.Allocate`, `Sys.Modify`, `Datastore.Audit`), not a header ([ADR-0005]).
- **Not covered (out of scope):** copying a backup to the local PC (neither provider documents a way, B15, B24);
  deleting a backup or a snapshot (B16); retention and scheduled backups; restoring into a new guest; Proxmox
  Backup Server; the Contabo automated-backup add-on; snapshots as a feature of their own ([UC-009]); and the
  stopping of a running guest.

## Consequences

**Positive:**

- The two providers are described in their own words before anything is sent: an archive on a storage, or a
  snapshot that is not an independent backup, and what a restore replaces; the text is kept with the operation
  as the evidence of what was accepted.
- A destructive restore uses the protection already built for removal (identifier typed, extra confirmation,
  running target refused, consequence recorded), so a user meets one habit for both.
- The write surface of backup and restore is a few named requests behind two capabilities, and the allow-list
  stays small and testable, with a stated rule that tells a creation from a restore ([ADR-0006], [ADR-0007],
  [ADR-0008]).
- The provider is the authority for what exists, so backups made by other tools can be listed and restored, and
  a backup deleted by the provider is reported as gone.
- `remove=0` guarantees that the product's dump never deletes an older backup.
- The restore at Proxmox VE can be proved end to end in the Docker Proxmox VE by a live round trip of
  [MIL-008] task 13, without any Contabo snapshot.

**Negative:**

- A Contabo snapshot is not a backup: it shares the disk system, is limited per product, may carry a cost that
  is not stated, and is deleted by the provider on its auto-delete date; the rollback deletes newer snapshots.
- The two providers do the same words differently, so a user must read the kind and the consequence.
- A restore over a Proxmox VE guest cannot be undone, and what `force` keeps or replaces is not documented
  (B13); the running-target refusal is a precaution for an undocumented behaviour (B12) and costs a separate
  shutdown step.
- The completion of a Contabo snapshot and rollback is inferred from the instance status and the snapshot list
  (B20), so a slow provider may end as `unknown` after the time limit.
- The restored Proxmox VE disks may land on the default storage when none is given; this is settled only by the
  live run.
- A local copy of a backup is not offered, so a backup that sits on the same host as the guest does not protect
  against the loss of the host (B25).
- A fourth narrow port per adapter, a second resolver method and a new record type.
- The live test needs `/dev/kvm` or emulation, and the Contabo snapshot and rollback are exercised only against
  the mock; no Contabo snapshot is created or rolled back by a test.

## Affected Artifacts

- [BC-001] — Objectives 1 to 3.
- [MIL-008] — task 2 delivers this ADR; Go criterion 1 requires it reviewed.
- [ADR-0002] — the capability model gains `backup_server` and `restore_server`, a fifth port and the backup
  kinds.
- [ADR-0005] — the Contabo token and request identifier apply to the snapshot and rollback requests; the
  permissions are named in errors.
- [ADR-0006] — operations are followed as before; the state rules and the write allow-list are extended.
- [ADR-0007] — the allow-list distinguishes a creation from a restore of the same path by the body.
- [ADR-0008] — the confirmation and protection rules of a removal are reused for a restore.
- [ADR-0009] — the file backup keeps the commands `server backup` and `server restore`; the new commands carry
  the prefix `full-`.
- [UC-006] — the operation is followed through the backup port for `BACKUP` and `RESTORE`.
- [UC-009] — snapshots as a feature stay out of scope.
- [UC-016] — the file backup is a different feature, not changed.
- [UC-018] — the use case this decision realises for backup.
- [UC-019] — the use case this decision realises for restore.

---

[BC-001]: ../business-case.md
[MIL-008]: ../milestones/mil-008-whole-server-backup-and-restore.md
[ADR-0002]: ./adr-0002-provider-capability-model.md
[ADR-0005]: ./adr-0005-contabo-credentials-and-token.md
[ADR-0006]: ./adr-0006-power-actions-and-operation-tracking.md
[ADR-0007]: ./adr-0007-desired-configuration-and-provisioning.md
[ADR-0008]: ./adr-0008-removal-of-a-server.md
[ADR-0009]: ./adr-0009-server-access-and-file-transfer.md
[UC-006]: ../use-cases/uc-006/uc.md
[UC-009]: ../use-cases/uc-009/uc.md
[UC-016]: ../use-cases/uc-016/uc.md
[UC-018]: ../use-cases/uc-018/uc.md
[UC-019]: ../use-cases/uc-019/uc.md
[9fd15f2]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/9fd15f248c031b5899ed480055d33b09a2ea62fa
