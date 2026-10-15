# Back up a whole server

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-018 |
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

DevOps chooses a server and asks for a backup of the whole server. The system checks that the provider supports it, starts the backup, follows it to completion (UC-006), and reports where the backup is kept and, where the provider allows, copies it to the local PC.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server exists and provider access is valid.
  - The provider supports whole-server backup for this server.
- **Postconditions (success guarantee):**
  - A backup of the server exists at the provider, or on the local PC where supported.
  - The operation and its outcome are recorded.

### Notes

- Includes UC-006.
- Proxmox VE has native backup (vzdump) and backup storage. Its API viewer lists upload and download-from-URL for storage, but not a plain download of a backup file; copying a backup to the local PC is open.
- Contabo documents only snapshots and object storage, no backup API; a backup there may be a snapshot kept at the provider, and whether it can be copied to the local PC is not stated (open).
- Capability check follows [ADR-0002]; the use case may be unsupported on a provider.
- Priority: Must.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[ADR-0002]: ../../adr/adr-0002-provider-capability-model.md
[31933c9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/31933c95a83dd3e114cc067cd907ddddb750b1bb
