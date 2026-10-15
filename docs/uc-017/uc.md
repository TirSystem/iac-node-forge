# Restore files from the local PC to the server

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-017 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | pending |

---

**Format:** Brief

## Brief

DevOps chooses files or folders on the local PC and a destination on a server. The system states which existing data would be overwritten and asks for confirmation, copies the data to the server, verifies that the copy is complete, and reports the result.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server is running and reachable, and DevOps can authenticate to it.
  - The data to restore exists on the local PC.
- **Postconditions (success guarantee):**
  - The data is on the server at the chosen destination and is verified complete.
  - Overwritten data is reported to DevOps before and after.

### Notes

- Provider-independent, as UC-016.
- Overwriting is destructive and needs the confirmation rules of UC-012; a server not managed by this client needs an extra confirmation.
- Whether the previous version of overwritten data is kept is open.
- Priority: Must.

---

[UCD-001]: ../use-case-diagram.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
