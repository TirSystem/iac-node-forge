# Operation Contracts: Restore a whole server from a backup

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-010 |
| CrossReference | [SSD-012], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-25 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-117 | pending |

---

## Contract: listBackups

| Item | Value |
| --- | --- |
| Operation | `listBackups(configuration: Text, serverIdentifier: Text): BackupListing` |
| Traces to | `listBackups` in [SSD-012] |
| Domain Model concepts | Backup, BackupKind, Operation, Server, Capability, ProviderConfiguration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- The provider declares the Capability `backup_server`.
- A Server with the identifier `serverIdentifier` exists at the provider.

**Postconditions**

- No instance was created, associated or modified, and no write request was sent.
- The result lists the Backups that the provider reports for the Server, which is the authority, each with its
  identifier, short alias, BackupKind, creation date, location, size where known, whether this client made it
  (the marker of this client in the notes of an archive, or the name prefix of a snapshot) and, where a Backup
  was recorded, the Operation that made it.
- The result lists separately the recorded Backups that the provider no longer lists. They are not deleted.
- A Backup that this client did not make is listed and marked as not made by this client.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The provider does not declare the Capability | Reported as unsupported; nothing is listed. |
| No such Server | Reported as not found; nothing is changed. |
| The provider cannot be reached or rejects the read | Reported with the reason, naming the permission where the provider reports one; nothing is changed. |

## Contract: previewRestore

| Item | Value |
| --- | --- |
| Operation | `previewRestore(configuration: Text, serverIdentifier: Text, backupId: Text): RestorePreview` |
| Traces to | `previewRestore` in [SSD-012] |
| Domain Model concepts | Server, ManagedServerRecord, Backup, BackupKind, RestoreEffect, Consequence, Capability, ProviderConfiguration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- The provider declares the Capability `restore_server`.
- A Server with the identifier `serverIdentifier` exists at the provider.
- A Backup identified by `backupId` (its identifier, or its short alias if that is unique among the Backups of
  the Server) is listed by the provider for the Server.
- The Backup can be restored into the Server: it is of the same kind of guest as the Server; the Server is not
  running where the provider requires it to be stopped first; and the Server is not cancelled or otherwise
  unavailable.

**Postconditions**

- No instance was created, associated or modified, and no restore request, and no other write request, was sent.
- The result states the provider, the Server (identifier, name and state), whether the Server is a managed
  server (a ManagedServerRecord that is not ended), and the Backup (identifier, alias, BackupKind, creation date
  and location).
- The result states the RestoreEffect: the Consequence text, which says what is replaced (for an `ARCHIVE`, the
  guest, its disks and its configuration, overwritten by the content of the archive; what the overwrite leaves
  untouched is not stated by the provider; for a `SNAPSHOT`, the state of the Server returns to the snapshot),
  the Backups that the restore deletes, by name and creation date, where the BackupKind is `SNAPSHOT`, that the
  cost is not stated where the provider does not state it, and that the restore cannot be undone.
- The result states that the identifier must be typed, and, when the Server is not a managed server, that one
  more confirmation is required.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The provider does not declare the Capability | Reported as unsupported; the preview is not offered. |
| No such Server | Reported as not found; nothing is changed. |
| No Backup is listed for `backupId`, or the alias is not unique | Reported as backup not found, with the reason; the preview is not offered. |
| The Backup is of another kind of guest than the Server | Reported as backup mismatch; the preview is not offered. |
| The Server is running where the provider requires it stopped | Reported as running, with the instruction to shut it down first; the Server is not stopped and the preview is not offered. |
| The Server is cancelled or otherwise unavailable | Reported as not available, with the state; the preview is not offered. |
| The provider cannot be reached or rejects the read | Reported with the reason; nothing is changed. |

## Contract: requestRestore

| Item | Value |
| --- | --- |
| Operation | `requestRestore(configuration: Text, serverIdentifier: Text, backupId: Text, confirmation: Confirmation): RestoreResult` |
| Traces to | `requestRestore` in [SSD-012] |
| Domain Model concepts | Operation, Consequence, RestoreEffect, Backup, Server, ManagedServerRecord, ProviderConfiguration ([DM-001]) |

**Preconditions**

- The preconditions of `previewRestore` hold.
- The confirmation was given for this ProviderConfiguration, Server and Backup, and the identifier typed equals
  the Server's identifier at the provider exactly (a display name or a prefix is not accepted).
- When the Server is not a managed server, the confirmation also holds the identifier typed again for the
  unmanaged Server, equal to the Server's identifier.

**Postconditions**

- Exactly one restore request was sent to the provider (for an `ARCHIVE`, the request that creates the guest of
  the same identifier from the archive and overwrites the existing guest; for a `SNAPSHOT`, one rollback request),
  and no other write request. The Server was not stopped, started or removed by this client, and no Backup was
  deleted by this client.
- An Operation instance was created with action `restore` and state `running`, associated with the
  ProviderConfiguration and the Server, with the Consequence text that was shown in the preview recorded with it.
- The Operation and its Consequence were persisted without any secret attribute.
- No other record was changed.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The confirmation is missing or refused, or the extra confirmation of an unmanaged Server is missing | Reported as not confirmed; no Operation is created and no request is sent. |
| The identifier typed, or the one typed again, differs from the Server's identifier | Reported as identifier mismatch; no Operation is created and no request is sent. |
| The provider does not declare the Capability | Reported as unsupported; nothing is created and no request is sent. |
| No such Server, no such Backup, or the Backup is of another kind of guest | Reported as in `previewRestore`; nothing is created and no request is sent. |
| The Server is running where the provider requires it stopped | Reported as running, with the instruction to shut it down first; nothing is created and no request is sent. |
| The Server is cancelled or otherwise unavailable | Reported as not available; nothing is created and no request is sent. |
| The provider rejects the request (authentication, permission, 4xx, 5xx) | The Operation is created with state `failed`, the reason (naming the permission where reported) as its detail and the Consequence recorded; the request is not repeated. |
| The request times out or the answer is lost | The Operation is created with state `unknown` and the Consequence recorded; the request is not repeated. |

## Contract: completeRestore

| Item | Value |
| --- | --- |
| Operation | `completeRestore(operationId: Text): RestoreResult` |
| Traces to | `completeRestore` in [SSD-012] |
| Domain Model concepts | Operation, Consequence, Server, ProviderConfiguration ([DM-001]) |

**Preconditions**

- An Operation with action `restore` and identifier `operationId` exists.
- The Operation is not in state `running`.

**Postconditions**

- When the Operation is `succeeded`: the state of the Server was read from the provider and recorded in the
  Operation's detail (attribute modified); the result states the Consequence recorded and the state of the
  Server. Nothing else was deleted or changed.
- When the Operation is `failed`: the result states the reason and the state left at the provider, read now.
- When the Operation is `unknown`: nothing was changed and the result says so; the state of the Server is read
  and reported where the provider can be reached.
- Completing again an Operation already completed changes nothing.
- The Operation was persisted without any secret attribute.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such Operation, or it is not a restore Operation | Reported as not found; nothing is changed. |
| The Operation is still `running` | Reported as not finished; nothing is changed. |
| The provider cannot be reached to read the state | The recording is done as above and the result says the state could not be read. |

---

[SSD-012]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
