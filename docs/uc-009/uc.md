# Manage snapshots

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-009 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [673a8e4] |

---

**Format:** Brief

## Brief

DevOps lists, creates, restores and deletes snapshots of a server where its provider supports them. The system checks that snapshots are supported for that server, asks for confirmation before a restore or deletion because they are destructive, follows each action to completion (UC-006), and reports the result.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server exists and provider access is valid.
  - The provider and target support snapshots for this server.
- **Postconditions (success guarantee):**
  - The snapshot exists, was restored or was deleted as requested, or the failure is reported.
  - The action and its outcome are recorded.

### Notes

- Includes UC-006.
- Proxmox VE snapshots depend on the storage type; Contabo snapshots depend on the plan and may have limits (verify).
- Capability check follows [ADR-0002].
- Priority: Should.

---

[UCD-001]: ../use-case-diagram.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
