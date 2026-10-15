# Credential storage

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0003 |
| CrossReference | [BC-001], [MIL-001], [ADR-0004], [UC-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Deprecated | Jens Tirsvad Nielsen | S02 | Initial version | [cd7ca06] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Decision shortened to two sentences; affected use case linked<br>Accepted after RC-006 | pending |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

The configuration files are JSONL, one per client, and must not hold tokens
or passwords ([BC-001], Objective 4). The providers need secrets:

- **Contabo:** client ID, client secret, API user and API password
  (assumed, to verify in MIL-001 task 4).
- **Proxmox VE:** an API token ID and secret, or a user and password.

The user is asked for these. Asking on every run is safe but tedious, so an
optional cache in the operating system credential store is wanted, gated by a
Windows Hello PIN where available. The Python CLI must also run on hosts
without Windows.

Options considered:

1. **Ask on every run, store nothing.** Safe, but unusable for repeated or
   scripted work.
2. **Store secrets in the JSONL or a file under the user's control.**
   Rejected: breaks the requirement.
3. **Optional cache in the OS credential store, with a reference name in the
   JSONL.** Windows: Credential Manager, and a Windows Hello check before the
   WinUI 3 application reads it. Other hosts: the platform keyring if present,
   otherwise ask on every run.

## Decision

The JSONL stores only a credential reference name per provider configuration; secrets are prompted for and cached in the operating system credential store only when the user agrees. On Windows both clients use Credential Manager, with a Windows Hello check in WinUI 3; on hosts without a keyring the secret is asked for on every run.

### Details

Use option 3. The JSONL stores only a credential reference name per provider
configuration, never the secret. Secrets are prompted for and cached in the
OS credential store only when the user agrees. On Windows both clients use
Credential Manager under one agreed target-name convention, so a secret can be
shared between them; the WinUI 3 application asks for a Windows Hello check
before reading it. On hosts without a keyring the secret is asked for on every
run and never written down.

## Consequences

**Positive:**

- No secret appears in the JSONL, in logs or in version control.
- The user chooses between convenience and asking every time.
- The same reference name works in both clients.

**Negative:**

- The Windows Hello check is an application-level gate in WinUI 3. Another
  process running as the same Windows user can still read Credential Manager,
  so this limits mistakes rather than a determined local attacker.
- The WinUI 3 `PasswordVault` is scoped per application and would not be
  shared with the CLI; the shared design therefore uses Credential Manager
  directly (to verify).
- A Windows Hello prompt from the Python CLI needs WinRT bindings and has not
  been verified; the CLI may simply use the stored secret without one.
- Behaviour differs per platform and must be tested on each.

## Affected Artifacts

- [BC-001] — Objective 4 and the secrets constraint.
- [MIL-001] — task 6 delivers this ADR; Go criterion 4 requires it accepted.
- [ADR-0004] — complements it for server access.
- [UC-001] — depends on this decision.

---

[BC-001]: ../business-case.md
[MIL-001]: ../milestones/mil-001-use-case-baseline.md
[cd7ca06]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/cd7ca06b28cdb5ab7298312602798e2b861bc908
[UC-001]: ../uc-001/uc.md
[ADR-0004]: ./adr-0004-server-access-credentials.md
