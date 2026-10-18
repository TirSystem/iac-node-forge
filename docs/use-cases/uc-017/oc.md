# Operation Contracts: Restore files from the local PC to the server

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-008 |
| CrossReference | [SSD-010], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-101 | pending |

---

## Contract: previewRestore

| Item | Value |
| --- | --- |
| Operation | `previewRestore(configuration: Text, serverIdentifier: Text, localPaths: List<Text>, remoteDestination: Text, acceptedFingerprint: Text [0..1]): TransferPreview` |
| Traces to | `previewRestore` in [SSD-010] |
| Domain Model concepts | Transfer, Overwrite preview, Server access, Host key, Managed server, Server, Provider configuration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- A Server with the identifier `serverIdentifier` exists at the provider and is running.
- A Server access is recorded for the Server, and an address to connect to is known.
- `localPaths` is not empty, each path exists on the local PC and can be read, and the final names of
  the paths are different from each other.
- `remoteDestination` is an absolute path with no `..` component, no line break and no NUL character.
- The Host key of the Server is known to the user (the user's `known_hosts` holds it), or
  `acceptedFingerprint` equals the fingerprint of the Host key the Server shows now.

**Postconditions**

- Nothing on the Server was created, changed or deleted: only read commands of the allow-list of
  [ADR-0009] were run there. Nothing was written on the local PC, and no Operation was created.
- The result states the provider, the Server (identifier, name, state), whether the Server is a
  Managed server, the host, port and user name used, the Host key and its fingerprint, the paths, the
  size of the data to copy, and whether the destination directory exists or will be created.
- The result holds the Overwrite preview: each existing item on the Server that the restore would replace
  (path, size, last changed), or that there is none, and states that the replaced data is not kept.
- The result states that the identifier of the Server must be typed, and, when the Server is not a
  Managed server, that one more confirmation is required.
- When `acceptedFingerprint` equalled the fingerprint of an unknown Host key, one line for that Host key
  was added to the user's `known_hosts`; this is the only write, and it is outside the Server.
- No Server access, Host key or Transfer record was persisted, and no secret was read, kept or reported.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such ProviderConfiguration, or no such Server | Reported as not found; nothing is changed. |
| The Server is not running | Reported as not running; nothing is changed. |
| No Server access is recorded, or no address is known | Reported as access missing, with the instruction to define it; nothing is changed. |
| A local path does not exist or cannot be read | Reported as path not found, with the path; nothing is changed. |
| A path is not valid, or two local paths have the same final name | Reported as an invalid path, with the path; nothing is changed. |
| The Host key is unknown and no fingerprint was accepted | Reported as host key unknown with the fingerprint; the Server is not read further and `known_hosts` is not changed. |
| The fingerprint given differs from the one the Server shows | Reported as host key unknown with the fingerprint shown now; `known_hosts` is not changed. |
| The Host key differs from the one in `known_hosts` | Reported as host key changed, with the instruction to correct `known_hosts` by hand; it is never accepted and the Server is not read further. |
| The connection or the log-in fails | Reported as a failed connection with the reason `ssh` gives, bounded and without any secret; nothing is changed. |
| The provider cannot be reached or rejects the read | Reported with the reason; nothing is changed. |

## Contract: requestRestore

| Item | Value |
| --- | --- |
| Operation | `requestRestore(configuration: Text, serverIdentifier: Text, localPaths: List<Text>, remoteDestination: Text, reportDirectory: Text, confirmation: Confirmation): TransferResult` |
| Traces to | `requestRestore` in [SSD-010] |
| Domain Model concepts | Transfer, Manifest, Transfer report, Overwrite preview, Managed server, Server access, Host key, Server ([DM-001]) |

**Preconditions**

- The preconditions of `previewRestore` hold, with the Host key known to the user.
- The confirmation was given for this ProviderConfiguration and Server, and the identifier typed equals
  the Server's identifier at the provider exactly (a display name or a prefix is not accepted).
- When the Server is not a Managed server, the confirmation also holds the identifier typed again for
  the unmanaged Server, equal to the Server's identifier.
- `reportDirectory` exists on the local PC or can be created.

**Postconditions**

- A Transfer instance was created with the direction restore, associated with the Server. The data of each
  local path exists on the Server under `remoteDestination` by its final name, and the destination
  directory was created when it did not exist; symbolic links were copied as links and not followed, and
  devices, sockets and pipes were skipped.
- Only the write commands of the allow-list of [ADR-0009] were run on the Server (the creation of the
  destination directory and the unpacking of the archive); nothing else on the Server was created,
  changed or deleted, and the previous version of a replaced item was not kept.
- Nothing was written on the Server before the confirmation held.
- A Manifest of the local data was made immediately before the copy and a Manifest of the copy on the
  Server after it, and the two are equal in every path, size and checksum, or the differences are listed.
- A Transfer report was created, shown, and saved as a file in `reportDirectory`. It states the files,
  links and bytes copied, anything skipped with the reason, the Overwrite preview as it stood just before
  the copy and the items that were replaced, the differences, and the verification result. It holds no
  secret.
- No Operation was created, no Managed server was changed, and `known_hosts` was not changed.
- The result is completed only when the Manifests are equal; otherwise it is reported as verification
  failed, with the differences.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The confirmation is missing or refused, or the extra confirmation of an unmanaged Server is missing | Reported as not confirmed; nothing is written on the Server. |
| The identifier typed, or the one typed again, differs from the Server's identifier | Reported as identifier mismatch; nothing is written on the Server. |
| Any other exception of `previewRestore` | The same outcome; nothing is written on the Server. |
| The copy differs from the source (a changed, missing or extra file) | Reported as verification failed with each difference; never reported as done; the data already written stays on the Server and the report says so. |
| The connection is lost, or the remote unpacking command fails, during the copy | Reported as transfer failed with the reason; the Server may hold part of the data, and the report says the restore is incomplete. |
| The report cannot be written | The result is reported with the reason and the verification result is still stated. |

---

[SSD-010]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[ADR-0009]: ../../adr/adr-0009-server-access-and-file-transfer.md
