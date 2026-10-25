# Operation Contracts: Back up a whole server

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-009 |
| CrossReference | [SSD-011], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-25 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-116 | [9fd15f2] |

---

## Contract: previewBackup

| Item | Value |
| --- | --- |
| Operation | `previewBackup(configuration: Text, serverIdentifier: Text, storage: Text [0..1]): BackupPreview` |
| Traces to | `previewBackup` in [SSD-011] |
| Domain Model concepts | Server, Backup, BackupKind, Consequence, Capability, ProviderConfiguration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- The provider declares the Capability `backup_server`.
- A Server with the identifier `serverIdentifier` exists at the provider.
- The Server can be backed up now: it is not cancelled or otherwise unavailable at the provider.
- Where the BackupKind is `ARCHIVE`: the storage named by `storage` accepts backups (its content list
  holds `backup`); when `storage` is empty, exactly one storage of the node accepts backups.
- Where the BackupKind is `SNAPSHOT`: `storage` is empty.

**Postconditions**

- No instance was created, associated or modified, and no backup request, and no other write
  request, was sent.
- The result states the provider, the Server (identifier, name and state), the BackupKind of the provider
  and where the Backup would be kept (the storage and its node for an `ARCHIVE`; the provider itself for a
  `SNAPSHOT`).
- The result states the Consequence text: for an `ARCHIVE`, that an archive is written to the storage, that it
  uses space there and that the Server keeps running (mode snapshot), with the size when it is known; for a
  `SNAPSHOT`, that it is a snapshot and not an independent backup, that it shares the disk system of the
  Server, that the provider limits the number of snapshots and may delete it on a date it sets, and that the
  cost is not stated.
- The result states that a plain confirmation is required and that none of the Server's existing data is
  changed.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The provider does not declare the Capability | Reported as unsupported; the preview is not offered. |
| No such Server | Reported as not found; nothing is changed. |
| The Server is cancelled or otherwise unavailable | Reported as not available, with the state; the preview is not offered. |
| No storage of the node accepts backups | Reported as no backup storage; the preview is not offered. |
| `storage` is empty and several storages accept backups | Reported as storage required, with the storages listed; the preview is not offered. |
| `storage` does not exist or does not accept backups | Reported as storage unsuitable, with the reason; the preview is not offered. |
| `storage` is given for a provider that has no storage | Reported as storage unsuitable; the preview is not offered. |
| The provider cannot be reached or rejects the read | Reported with the reason, naming the permission where the provider reports one; nothing is changed. |

## Contract: requestBackup

| Item | Value |
| --- | --- |
| Operation | `requestBackup(configuration: Text, serverIdentifier: Text, storage: Text [0..1], confirmation: Confirmation): BackupResult` |
| Traces to | `requestBackup` in [SSD-011] |
| Domain Model concepts | Operation, Consequence, BackupKind, Server, ProviderConfiguration ([DM-001]) |

**Preconditions**

- The preconditions of `previewBackup` hold.
- The confirmation was given for this ProviderConfiguration and Server.

**Postconditions**

- Exactly one backup request was sent to the provider for the Server (for an `ARCHIVE`, one dump request that
  carries the marker of this client and removes no older backup; for a `SNAPSHOT`, one snapshot request with a
  name and a description that identify this client), and no other write request. The Server was not changed,
  stopped or restarted by this client.
- An Operation instance was created with action `backup` and state `running`, associated with the
  ProviderConfiguration and the Server, with the Consequence text that was shown in the preview recorded with
  it.
- The Operation and its Consequence were persisted without any secret attribute.
- No Backup instance was recorded yet.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The confirmation is missing or refused | Reported as not confirmed; no Operation is created and no request is sent. |
| The provider does not declare the Capability | Reported as unsupported; nothing is created and no request is sent. |
| No such Server | Reported as not found; nothing is created and no request is sent. |
| The Server is not available, or the storage condition fails | Reported as in `previewBackup`; nothing is created and no request is sent. |
| The provider rejects the request (authentication, permission, a limit, 4xx, 5xx) | The Operation is created with state `failed`, the reason (naming the permission where reported) as its detail and the Consequence recorded; no Backup is recorded and the request is not repeated. |
| The request times out or the answer is lost | The Operation is created with state `unknown` and the Consequence recorded; the request is not repeated. |

## Contract: completeBackup

| Item | Value |
| --- | --- |
| Operation | `completeBackup(operationId: Text): BackupResult` |
| Traces to | `completeBackup` in [SSD-011] |
| Domain Model concepts | Operation, Backup, BackupKind, Server, ProviderConfiguration ([DM-001]) |

**Preconditions**

- An Operation with action `backup` and identifier `operationId` exists.
- The Operation is not in state `running`.

**Postconditions**

- When the Operation is `succeeded` and the provider lists the Backup it made (for an `ARCHIVE`, the newest
  archive of the guest made at or after the start of the Operation that carries the marker of this client; for a
  `SNAPSHOT`, the snapshot the request created): a Backup instance was recorded with its identifier, kind,
  location and creation date, associated with the Operation, the Server and the ProviderConfiguration; it was
  persisted without any secret attribute. The result states where the Backup is kept (the location, the
  identifier and its short alias), its kind and, where the provider reports it, the date on which the provider
  deletes it.
- When the Operation is `succeeded` but the provider does not list the Backup: no Backup was recorded, and the
  result says that the backup could not be located.
- When the Operation is `failed`: no Backup was recorded, and the result states the reason and the state left at
  the provider.
- When the Operation is `unknown`: nothing was changed and the result says so.
- Completing again an Operation whose Backup is already recorded records no second Backup.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such Operation, or it is not a backup Operation | Reported as not found; nothing is changed. |
| The Operation is still `running` | Reported as not finished; nothing is changed. |
| The provider cannot be reached to locate the Backup | Reported with the reason; no Backup is recorded and the result says that the backup could not be located. |

---

[SSD-011]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[9fd15f2]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/9fd15f248c031b5899ed480055d33b09a2ea62fa
