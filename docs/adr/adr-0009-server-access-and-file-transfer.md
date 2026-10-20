# Server access and file transfer

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0009 |
| CrossReference | [BC-001], [MIL-007], [ADR-0001], [ADR-0004], [ADR-0006], [ADR-0008], [UC-006], [UC-012], [UC-014], [UC-016], [UC-017], [UC-018], [UC-019] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Deprecated | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-095 | [f05b1dd] |
| 2026-10-20 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Revision 2: a restore does not fail on files that were already on the server<br>Accepted after RC-104 | [12e95a3] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Every earlier decision record concerns the provider's interface. The backup of files (UC-016) and their
restore (UC-017) talk to the server itself, over SSH. [ADR-0004] is binding and already decides what
the product may not do: it never stores a private key or a server password, it uses the user's agent, key
files and `known_hosts`, an unknown host key needs explicit acceptance, a changed host key stops the
transfer, and a restore follows the confirmation rules of removal ([ADR-0008]) with an extra
confirmation for a server not managed by this client. It leaves open how the transfer is performed, what
connection facts are kept, how a copy is shown to be complete and how room is checked. The forces are:

- A copy that is reported as done but is incomplete or different is worse than a failure: the user may
  delete the server afterwards ([UC-012]). Verification is the point of the slice.
- A restore overwrites data on a machine that may not be managed by this client, and the product cannot
  undo it.
- A backup must change nothing on the server, so the set of commands run there must be small and
  checkable.
- A server may be a minimal image (BusyBox, no `rsync`, no `sftp-server`); the user's machine may be
  Windows 10 or later or Linux.
- The configuration file holds no secret ([BC-001], Objective 4), and the transfer needs no new
  credential store.
- The provider reports the addresses of a server, but the user name, port and key belong to the server's
  setup, not to the provider.

Options considered for the transfer method:

1. **An SSH library in the process** (for example Paramiko or asyncssh). One process and fine control, but
   it does not read the user's `ssh_config`, agent behaviour and `known_hosts` the way `ssh` does, so it
   would have to re-implement the rules of [ADR-0004] and adds a dependency that carries the user's keys
   through the product's memory.
2. **The system's OpenSSH client started as a process**, with `ssh-keyscan` and `ssh-keygen` for host
   keys. It honours the agent, key files, `ssh_config` and `known_hosts` exactly, and a password or
   passphrase prompt stays with `ssh` itself. It needs the OpenSSH client on the machine (present on
   Windows 10 and later and on Linux).
3. **`scp`, `sftp` or `rsync`.** `rsync` is missing on Windows and on many minimal servers; `scp` and
   `sftp` need a server-side subsystem, give no manifest, and follow links in different ways.

Options considered for the data movement over `ssh`: a tar stream, or one `ssh` call per file. The tar
stream is one connection, keeps directories and links, works with BusyBox `tar`, and is read as it
arrives; a call per file is slow and makes a partial result harder to describe.

Options considered for the host key: accept new keys silently (`StrictHostKeyChecking=accept-new`),
switch checking off, or check strictly and let the user accept a shown fingerprint explicitly. The first
two defeat the purpose of the check.

Options considered for verification: trust the exit status of the tools; compare the number of files and
their sizes; or compare a manifest with a SHA-256 hash of every regular file on both sides. Only the last
finds one changed byte.

Options considered for the connection facts: add them to the provider configuration, keep one record per
server, or ask for them on every run. They differ per server and are not secrets, so one record per server
is the smallest place that stays correct.

Options considered for the data a restore overwrites: keep the previous version (a renamed copy or an
archive on the server), or do not keep it. A kept copy needs room on the server, another set of write
commands and a rule for removing it.

Options considered for recording a transfer: an `Operation` record like a power action, or a report. An
`Operation` follows a provider task ([ADR-0006]); a transfer has no provider task, runs in the process of
the command and ends when it ends.

## Decision

The product reaches a server by starting the system's OpenSSH tools (`ssh`, `ssh-keyscan`, `ssh-keygen`)
as processes and moving data as a tar stream over `ssh`, and it keeps only the host, port, user and an
identity hint per server in the JSON Lines file; the host key is always checked strictly, a copy is
reported as done only when a SHA-256 manifest of the destination equals that of the source, and a restore
lists what it would overwrite and needs the identifier typed (and typed again for a server not managed by
this client) before it writes a byte. The previous version of an overwritten file is not kept.

### Rules

- **Method:** `ssh` is started with fixed options and a fixed command template. No SSH library is added.
  A later WinUI 3 client may not be allowed to start programs and may then need a library; it must honour
  the same rules (agent, key files, `known_hosts`, strict host key, no stored secret, verification).
- **Connection facts:** a new record type `server_access`, key (`configuration_id`, `server_identifier`),
  in the existing JSON Lines file, with `host`, `port`, `user` and `identity_hint`.
  - `host` is optional; when it is empty the first address the provider reports for the server
    (`Server.addresses`, without a prefix length) is used at the time of the transfer, so a changed
    address is followed. `port` defaults to 22. `user` is required: there is no default of `root`.
  - `identity_hint` is free text, never a key. When it names an existing file it is passed to `ssh` as
    `-i`; a path to a public key file selects the matching key held by the agent. Otherwise it is only
    shown. With no hint, `ssh` decides from the agent, `ssh_config` and the default key files.
  - No password, passphrase, key or token is stored, written to a report, placed on a command line or in an
    environment variable, or printed in an error text. A password or passphrase prompt is left to `ssh` on
    the inherited terminal; the product never reads it. A run that has no terminal to ask (the command
    runs non-interactively) starts `ssh` with `BatchMode=yes`, so it fails instead of waiting.
- **Host key:** `StrictHostKeyChecking=yes` on every `ssh` call.
  - Before a transfer the host key is read with `ssh-keyscan` and its fingerprint with `ssh-keygen -lf`,
    and compared with the entries `ssh-keygen -F` finds in the user's `known_hosts`: `KNOWN` (a scanned key
    matches), `UNKNOWN` (no entry for the host) or `CHANGED` (the host has an entry and no scanned key
    matches).
  - `UNKNOWN` stops the transfer and shows the fingerprint. The user may run again with the fingerprint
    (`--accept-host-key <fingerprint>`); it must equal the scanned fingerprint, and then the key is appended
    to the user's `known_hosts` (`[host]:port` when the port is not 22). This line is the only thing the
    product writes outside the destination and the report, and only on that explicit act.
  - `CHANGED` stops the transfer and is never accepted by the product, with any option. The user fixes
    `known_hosts` by hand.
  - A refusal by `ssh` itself that this check did not predict (for example a `UserKnownHostsFile` in
    `ssh_config`) is reported with the text of `ssh` as a failed connection.
- **Data movement:**
  - Backup: the remote command `tar -cf - -C / -- <paths>` is read from the stdout of `ssh` and unpacked
    with Python's `tarfile` using the `data` extraction filter. Absolute names, `..`, links that point
    outside the destination, devices and set-user-id bits are refused by the filter, and a member whose
    name is not under a requested path is refused as well. Each remote path is absolute and normalised;
    it is placed under the destination at its full path (`/etc/nginx` becomes `<destination>/etc/nginx`).
  - Restore: a tar stream of the local paths, written by `tarfile` without following links, goes to the
    remote command `tar -xf - -C <destination>` on the stdin of `ssh`. Each local path is placed under the
    remote destination by its name.
  - Symbolic links are copied as links and never followed. Devices, sockets and pipes are skipped and
    listed in the report. Modes and owners are not part of the manifest; the remote tar sets the owner to
    the connecting user where it supports `--no-same-owner`.
- **Allow-list of remote commands:** built from fixed templates; every path is an argument quoted for a
  POSIX shell and follows `--`; no user text is concatenated into a command unquoted.
  - Reads (a backup runs only these): `tar -cf -`, `find` (its `-exec` runs only `sha256sum`, `stat` or
    `readlink`), `sha256sum`, `stat -c`, `readlink`, `du -sk`.
  - Writes (a restore only): `tar -xf - -C <destination>` and `mkdir -p -- <destination>`.
  - Nothing else: no `rm`, `mv`, `cp`, `chmod`, `chown`, no shell redirection to a file. A test lists the
    remote commands the fake can receive, as the write requests are listed in [ADR-0006].
- **Manifest and verification:** the manifest has, for every regular file, its path relative to the
  destination, its size and its SHA-256, and for every link its target. It is computed on the source side
  (remote with `find` and `sha256sum`, local with `hashlib`) immediately before the copy and on the
  destination side after it. A backup is `FAILED` on any difference, a missing file or an extra file, because
  its destination starts empty. A restore adds and overwrites and never deletes, so it is `FAILED` only on a
  missing or changed file; a file that already existed on the server and is not part of the restored data is
  left in place, and the report says how many there are (a note), without failing the restore. In both cases
  the transfer is never reported as done while a file is missing or differs. A file that changes while it is copied shows as a
  difference, and the user runs the transfer again.
- **Room (backup):** the remote total is `du -sk` (kilobytes, accepted by BusyBox) of the chosen paths and
  must fit, with a margin of 10 percent plus 16 MiB, in `shutil.disk_usage` of the destination. If it does
  not, the backup is refused with the sizes before anything is copied. A restore does not check room on
  the server; a failure of the remote `tar` is reported with its text.
- **Destination of a backup:** a directory that does not exist or is empty, so a backup never overwrites
  local files; otherwise it is refused. The report is written to it after the verification.
- **Restore protection:** before any write, the destination paths that exist on the server are listed
  (path, size, modification time) and the preview warns that they are overwritten and not kept. Then, as in
  [ADR-0008]: the server identifier is always typed (interactively retyped; non-interactively `--yes` with
  the identifier argument), a server not managed by this client needs it typed again
  (`--confirm-unmanaged <identifier>`), a mismatch sends nothing, and without a valid confirmation nothing
  is written. The files overwritten are reported before (the preview) and after (the report).
- **Server and address:** the server must exist at the provider and be running; the provider is read for
  that and for the address. A transfer to a server the provider does not know is not offered.
- **Record of a transfer:** no `Operation` is created, and [UC-006] is not involved: there is no provider
  task to follow, and the command waits for its own end. The result is a transfer report (direction,
  server, counts of files, links and skipped entries, bytes, the differences if any, the files overwritten
  and the verification result). It is shown and saved as a local file: for a backup in the destination,
  for a restore in the directory the user names. It holds no secret. An interrupted transfer is not
  resumed; a partial destination is left in place and reported as incomplete.
- **Platforms:** local paths use `pathlib`, remote paths are POSIX. On Windows the OpenSSH client is a
  Windows feature and its agent is a service that is stopped by default; `known_hosts` is in the user's
  `.ssh` folder. Local modes carry no meaning on Windows and are not verified. Untested until the live
  run: the Windows agent, and password-only servers.
- **Not covered:** provider-level backups ([UC-018], [UC-019]), SFTP and rsync, resume, compression
  choices, adoption of an unmanaged server, the placing of keys on a server ([UC-014]) and WinUI 3.

## Consequences

**Positive:**

- The agent, key files, `ssh_config` and `known_hosts` of the user are honoured by the tool that owns
  them, and the product holds no key or password at any time ([ADR-0004]).
- One changed byte is found, because both sides are compared by hash, not by status or size.
- A backup is provably read-only: the remote commands are a short list that a test can check.
- The same code serves Proxmox VE guests and Contabo instances, and works on BusyBox images.
- A restore names what it overwrites before it writes, and the second typing protects a server this
  client does not manage.
- The contract suite can run the same behaviours against an in-process fake and, opt-in, a real OpenSSH
  server in a container ([ADR-0001]).

**Negative:**

- The OpenSSH client must be installed; on Windows the agent must be started by the user.
- Hashing every file reads the data twice on the server and on the PC, so a large backup takes longer.
- `du -sk` is disk usage, not the logical size, and sparse files can need more room than it shows; the
  margin covers common cases only.
- A busy file (a log that grows during the copy) is reported as a difference and the transfer as failed.
- The previous version of an overwritten file is lost; the preview and the report are the only
  safeguards.
- A host key fingerprint shown to the user is only as safe as the user's comparison with another source;
  the product cannot do that comparison.
- A password-only server asks for the password on every use, and an interrupted transfer starts again
  from the beginning.
- A WinUI 3 client may need an SSH library and then a second implementation of the same rules.
- Mode and owner of files are not verified.

## Affected Artifacts

- [BC-001] — Objective 4 (no secrets in configuration) and Objective 3 (the same capabilities in every
  client).
- [MIL-007] — task 1 delivers this record; Go criterion 1 requires it reviewed.
- [ADR-0001] — the transfer contract suite runs against a fake and, opt-in, a real server.
- [ADR-0004] — this record carries out its rules and settles the transfer method it left open.
- [ADR-0006] — the confirmation rules and the write allow-list idea are extended to the remote commands;
  a transfer is not an operation of that record.
- [ADR-0008] — the confirmation rules of removal are reused for a restore.
- [UC-006] — not involved, as stated in the rule on the record of a transfer.
- [UC-016], [UC-017] — the use cases this decision realises.
- [UC-012] — its confirmation rules are reused through [ADR-0008]; a backup is a precaution before a
  removal.
- [UC-014], [UC-018], [UC-019] — named as not covered; this decision does not change them.

---

[BC-001]: ../business-case.md
[MIL-007]: ../milestones/mil-007-file-backup-and-restore.md
[ADR-0001]: ./adr-0001-provider-test-strategy.md
[ADR-0004]: ./adr-0004-server-access-credentials.md
[ADR-0006]: ./adr-0006-power-actions-and-operation-tracking.md
[ADR-0008]: ./adr-0008-removal-of-a-server.md
[UC-006]: ../use-cases/uc-006/uc.md
[UC-012]: ../use-cases/uc-012/uc.md
[UC-014]: ../use-cases/uc-014/uc.md
[UC-016]: ../use-cases/uc-016/uc.md
[UC-017]: ../use-cases/uc-017/uc.md
[UC-018]: ../use-cases/uc-018/uc.md
[UC-019]: ../use-cases/uc-019/uc.md
[f05b1dd]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/f05b1dd98b3282a9b01ed2875fb706e6326af769
[12e95a3]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/12e95a3bc848a2052a13f96f7ce48c1a271bb349
