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
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-018 | pending |

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
- Proxmox VE has snapshots with rollback for VMs and containers; dependence on storage type is not in the API viewer (open).
- Contabo snapshot names are limited to 30 characters, and a rollback deletes all newer snapshots, so the confirmation must say so (verified). The number of snapshots allowed is not stated (open).
- Capability check follows [ADR-0002].
- Priority: Should.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[ADR-0002]: ../../adr/adr-0002-provider-capability-model.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
