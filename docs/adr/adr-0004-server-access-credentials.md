# Server access credentials

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0004 |
| CrossReference | [BC-001], [MIL-001], [ADR-0003], [UC-005], [UC-016], [UC-017] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Initial version | [e80473e] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Decision shortened to two sentences; affected use cases linked<br>Accepted after RC-007 | [b664ca3] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Two use cases transfer data between the local PC and a server: back up server
files (UC-016) and restore files to the server (UC-017). Bootstrap after
provisioning (UC-005) may also need to log in to the server. These use cases
talk to the server itself, over SSH, not to the provider API.

[ADR-0003] covers the provider credentials (Proxmox VE token, Contabo client
and API user). It does not cover logging in to a server. The forces are:

- The configuration files are JSONL and must not hold secrets ([BC-001],
  Objective 4).
- Most DevOps users already have SSH keys, an agent and a `known_hosts` file.
  Duplicating them in the product creates a second place for private keys.
- The same server can be reached by an IP address the provider reports, but
  the user name, port and key are a property of the server's setup, not of
  the provider.
- Restore overwrites data, so a wrong or spoofed server is costly.
- Two clients must behave alike: a Python CLI (any operating system) and a
  WinUI 3 application distributed through the Microsoft Store, which may not
  be allowed to start arbitrary programs.

Options considered:

1. **The product stores private keys and passwords** in its own store.
   Rejected: a second copy of the most sensitive material, and a larger
   target.
2. **Ask for the key or password on every use.** Safe, but unusable for
   repeated transfers and impossible for a passphrase-protected key without
   an agent.
3. **Use the user's existing SSH identity** (key files and the SSH agent)
   and the user's `known_hosts`, keeping only a reference in the JSONL.

## Decision

The product never stores a private key or a server password: it uses the user's SSH agent, key files and `known_hosts`, and keeps only non-secret connection facts in the JSONL. A password is prompted for on every use, and an unknown or changed host key stops the transfer until DevOps decides.

### Rules

Use option 3. The product never stores a private key or a password.

- The JSONL holds, per server, only non-secret connection facts: host or
  provider server reference, port, user name, and a hint for the identity (a
  key file path or an agent identity name).
- Authentication is by key through the user's SSH agent or key file. A key
  passphrase is handled by the agent or prompted for and not stored.
- A password, where a server only allows passwords, is prompted for on every
  use and is not cached. Caching it is not offered, because [ADR-0003]'s
  credential store is for provider secrets.
- The server's host key is checked against the user's `known_hosts`. An
  unknown host key is shown to DevOps and needs explicit acceptance before
  it is added. A changed host key stops the transfer; it is never
  accepted automatically.
- A restore to a server follows the confirmation rules of removal (UC-012),
  with an extra confirmation for a server not managed by this client.
- How the transfer is performed (the system's OpenSSH tools or an SSH
  library) is a design decision for the clients. Both must honour the
  agent, the key files and `known_hosts` as above.

## Consequences

**Positive:**

- No private key or server password is stored by the product.
- It reuses the user's existing SSH setup and trust decisions.
- Host key verification protects against spoofed servers, which matters for a
  restore that overwrites data.
- The CLI and WinUI 3 behave the same and need no new credential store.

**Negative:**

- Transfers depend on the user's SSH setup (agent running, key available).
  A user without one has to create it first, and the product gives guidance
  rather than a one-click setup.
- Password-only servers are tedious: a prompt on every use.
- The WinUI 3 app may not be able to start the system's OpenSSH tools from a
  Store package; it may need an SSH library, which must then match the same
  agent and `known_hosts` behaviour.
- Host-key and agent behaviour differ between operating systems and must be
  tested on each.

**Open items:**

- How a new server's access key pair is created and the public key placed
  (provider secrets, UC-014) is not decided here.
- Whether a Windows Hello check gates the use of an identity is not decided.

## Affected Artifacts

- [BC-001] — Objective 4 (no secrets in configuration).
- [MIL-001] — a fourth decision record for the baseline; Go criterion 4 names it.
- [ADR-0003] — complements it: provider credentials there, server access here.
- [UC-005], [UC-016], [UC-017] — depend on this decision.

---

[BC-001]: ../business-case.md
[MIL-001]: ../milestones/mil-001-use-case-baseline.md
[ADR-0003]: ./adr-0003-credential-storage.md
[e80473e]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/e80473e106402eeb44c0148b3fa34777c1bc7bd1
[UC-005]: ../uc-005/uc.md
[UC-016]: ../uc-016/uc.md
[UC-017]: ../uc-017/uc.md
[b664ca3]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/b664ca34d52e7c4fe1561279e213dd6ffbeca3d5
