# Start, stop and restart a server

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-008 |
| CrossReference | [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | pending |

---

**Format:** Brief

## Brief

DevOps selects a server and asks to start, stop or restart it. The system checks that the provider supports the action, asks for confirmation where the action is forced or the server is not managed by this client, performs it, follows it to completion (UC-006), and reports the resulting state.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server exists and its provider access is valid.
  - The provider supports the requested action for this server.
- **Postconditions (success guarantee):**
  - The server is in the requested state, or the failure is reported.

### Notes

- Graceful versus forced stop is open (Proxmox VE has both; verify for Contabo).
- Servers not managed by this client need an extra confirmation.
- Capability check follows [ADR-0002].

---

[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
