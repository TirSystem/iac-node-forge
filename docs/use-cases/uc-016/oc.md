# Operation Contracts: Back up server files to the local PC

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-007 |
| CrossReference | [SSD-009], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-099 | pending |

---

## Contract: defineServerAccess

| Item | Value |
| --- | --- |
| Operation | `defineServerAccess(configuration: Text, serverIdentifier: Text, host: Text [0..1], port: Integer [0..1], user: Text, identityHint: Text [0..1]): ServerAccessView` |
| Traces to | `defineServerAccess` in [SSD-009] |
| Domain Model concepts | Server access, Server, Provider configuration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- A Server with the identifier `serverIdentifier` exists at the provider.
- `user` is given and is not empty; there is no default user.
- `port`, when given, is between 1 and 65535; when it is not given it is 22.
- `host`, when given, is a name or an address without spaces and without a leading `-`; when it is not
  given the address the provider reports for the Server is used at the time of each transfer.
- `identityHint`, when given, is at most 500 characters and is not key material.

**Postconditions**

- A Server access instance was created, or the one for the same ProviderConfiguration and Server was
  replaced, associated with that Server, with the host (or none), the port, the user name and the identity
  hint.
- The Server access was persisted without any secret attribute: no password, passphrase, key or token.
- No connection to the Server was made, nothing was sent to the Server or to the provider but the read
  of the Server, and no other record was created, associated or modified.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such ProviderConfiguration | Reported as not found; nothing is kept. |
| No such Server | Reported as not found; nothing is kept. |
| The user name is missing | Reported as invalid with the reason; nothing is kept. |
| The port is outside the range, or the host is not valid | Reported as invalid with the reason; nothing is kept. |
| The identity hint is longer than allowed or looks like key material | Reported as invalid; nothing is kept and the value is not repeated in the report. |
| The provider cannot be reached or rejects the read | Reported with the reason; nothing is kept. |

## Contract: previewBackup

| Item | Value |
| --- | --- |
| Operation | `previewBackup(configuration: Text, serverIdentifier: Text, remotePaths: List<Text>, destination: Text, acceptedFingerprint: Text [0..1]): TransferPreview` |
| Traces to | `previewBackup` in [SSD-009] |
| Domain Model concepts | Transfer, Server access, Host key, Server, Manifest, Provider configuration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- A Server with the identifier `serverIdentifier` exists at the provider and is running.
- A Server access is recorded for the Server, and an address to connect to is known: the recorded host,
  or an address the provider reports.
- `remotePaths` is not empty, and each path is absolute, with no `..` component, no line break and no
  NUL character.
- `destination` does not exist or is an empty directory.
- The Host key of the Server is known to the user (the user's `known_hosts` holds it), or
  `acceptedFingerprint` equals the fingerprint of the Host key the Server shows now.

**Postconditions**

- Nothing on the Server was created, changed or deleted: only read commands of the allow-list of
  [ADR-0009] were run there. Nothing was created at the destination, and no Operation was created.
- The result states the provider, the Server (identifier, name, state), the host, port and user name
  used, the Host key and its fingerprint, the paths, the size of the data to copy, the room free at the
  destination, the margin required, and that nothing on the Server is changed.
- When `acceptedFingerprint` equalled the fingerprint of an unknown Host key, one line for that Host key
  was added to the user's `known_hosts`; this is the only write, and it is outside the Server and the
  destination.
- No Server access, Host key or Transfer record was persisted, and no secret was read, kept or reported.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such ProviderConfiguration, or no such Server | Reported as not found; nothing is changed. |
| The Server is not running | Reported as not running; nothing is changed. |
| No Server access is recorded, or no address is known | Reported as access missing, with the instruction to define it; nothing is changed. |
| A path is not valid, or the destination is not new or empty | Reported as an invalid path, or as a destination that is not empty, with the path; nothing is changed. |
| The Host key is unknown and no fingerprint was accepted | Reported as host key unknown with the fingerprint; the Server is not read further and `known_hosts` is not changed. |
| The fingerprint given differs from the one the Server shows | Reported as host key unknown with the fingerprint shown now; `known_hosts` is not changed. |
| The Host key differs from the one in `known_hosts` | Reported as host key changed, with the instruction to correct `known_hosts` by hand; it is never accepted and the Server is not read further. |
| The connection or the log-in fails (unreachable, refused, not authenticated) | Reported as a failed connection with the reason `ssh` gives, bounded and without any secret; nothing is changed. |
| A remote path does not exist | Reported as path not found, with the path; nothing is changed. |
| The destination has less room than the data plus the margin | Reported as no room, with the size, the room free and the margin; nothing is changed. |
| The provider cannot be reached or rejects the read | Reported with the reason; nothing is changed. |

## Contract: requestBackup

| Item | Value |
| --- | --- |
| Operation | `requestBackup(configuration: Text, serverIdentifier: Text, remotePaths: List<Text>, destination: Text): TransferResult` |
| Traces to | `requestBackup` in [SSD-009] |
| Domain Model concepts | Transfer, Manifest, Transfer report, Server access, Host key, Server ([DM-001]) |

**Preconditions**

- The preconditions of `previewBackup` hold, with the Host key known to the user.
- The destination has room for the data and the margin.

**Postconditions**

- A Transfer instance was created with the direction backup, associated with the Server. The data of each
  remote path exists under the destination at its full path (`/etc/nginx` as `<destination>/etc/nginx`);
  symbolic links were copied as links and not followed, and devices, sockets and pipes were skipped.
- A Manifest of the data at the Server was made immediately before the copy and a Manifest of the copy
  after it, and the two are equal in every path, size and checksum, or the differences are listed.
- A Transfer report was created and saved as a file in the destination, and shown. It states the
  files, links and bytes copied, anything skipped with the reason, the differences, and the verification
  result. It holds no secret.
- Nothing on the Server was created, changed or deleted. No Operation was created, no Managed server was
  changed, and `known_hosts` was not changed.
- The result is completed only when the Manifests are equal; otherwise it is reported as verification
  failed, with the differences, and the copied data stays at the destination marked as unverified in the
  report.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| Any exception of `previewBackup` | The same outcome; nothing is copied and the destination is not created. |
| The copy differs from the source (a changed, missing or extra file) | Reported as verification failed with each difference; never reported as done. |
| The connection is lost, or the remote archive command fails, during the copy | Reported as transfer failed with the reason; the data copied so far stays at the destination and the report says it is incomplete. |
| A file changes at the Server while it is copied | Shows as a difference and is reported as verification failed; the transfer is not repeated by the system. |
| The report cannot be written | The result is reported with the reason and the verification result is still stated. |

---

[SSD-009]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[ADR-0009]: ../../adr/adr-0009-server-access-and-file-transfer.md
