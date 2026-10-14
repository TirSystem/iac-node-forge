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
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [673a8e4] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | pending |

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

[UCD-001]: ../use-case-diagram.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
