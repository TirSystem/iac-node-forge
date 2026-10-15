# Restore a whole server from a backup

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-019 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [31933c9] |

---

**Format:** Brief

## Brief

DevOps chooses a backup and a target. The system states what the restore will replace and what it costs, asks for explicit confirmation, starts the restore, follows it to completion (UC-006), and reports the state of the restored server.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - A backup exists at the provider or on the local PC.
  - The provider supports restoring it, and provider access is valid.
- **Postconditions (success guarantee):**
  - The server is restored from the backup, or the failure and the state left are reported.
  - The consequence shown to DevOps is recorded with the operation.

### Notes

- Includes UC-006.
- Proxmox VE restores a backup into a VM; whether an existing VM is replaced or a new one created is a choice to state.
- Contabo restores through snapshot rollback, which deletes newer snapshots (verified in the verification note); restoring from a file on the local PC is not documented (open).
- Restore is destructive and follows the confirmation rules of UC-012.
- Capability check follows [ADR-0002].
- Priority: Must.

---

[UCD-001]: ../use-case-diagram.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[31933c9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/31933c95a83dd3e114cc067cd907ddddb750b1bb
