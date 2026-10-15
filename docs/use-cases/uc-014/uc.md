# Manage SSH keys and secrets

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-014 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-023 | pending |

---

**Format:** Brief

## Brief

DevOps registers and reuses public SSH keys and other provider-side secrets that servers need. The system stores them where the provider expects them, lets them be referenced from desired configurations, and removes them on request.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - Provider access is valid (UC-001).
- **Postconditions (success guarantee):**
  - The key or secret is available at the provider and can be referenced by name.
  - No private key or password is stored in the client's configuration.

### Notes

- Contabo has a secrets API with types ssh and password, referenced by ID at creation and reinstall (verified). Proxmox VE keys are passed through cloud-init configuration; template requirements are open.
- May be folded into UC-003 or UC-001 later.
- Credential handling follows [ADR-0003].
- Priority: Open.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[ADR-0003]: ../../adr/adr-0003-credential-storage.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
