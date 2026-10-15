# Resize, reinstall or rescue a server

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-015 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-024 | [d4593ae] |

---

**Format:** Brief

## Brief

DevOps asks to change an existing server by resizing it, reinstalling its image, or booting it into a rescue mode. The system states what the change means at that provider and what it destroys, asks for explicit confirmation, performs it, follows it to completion (UC-006), and reports the result.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server exists and provider access is valid.
  - The provider supports the requested change for this server.
- **Postconditions (success guarantee):**
  - The server is changed as requested, or the failure is reported.
  - The consequence shown to DevOps is recorded with the operation.

### Notes

- Contabo offers reinstall and rescue (verified). Its upgrade documentation is inconsistent (add-ons only versus product upgrade), so resize stays open. Proxmox VE resize is a configuration and disk edit (verified).
- Provider differences are large; capability check follows [ADR-0002].
- A reinstall destroys data and needs the confirmation rules of UC-012.
- Priority: Open.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[ADR-0002]: ../../adr/adr-0002-provider-capability-model.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
[d4593ae]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d4593aee3a0196cb5ced87130a3194ed20600c22
