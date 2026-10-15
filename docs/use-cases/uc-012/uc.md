# Delete or cancel a server

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-012 |
| CrossReference | [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [25d8548] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |

---

**Format:** Brief

## Brief

DevOps selects a server and asks to remove it. The system states what removal means at that provider, for example destroyed now or cancelled with an effective date, and asks for explicit confirmation, with an extra confirmation if the server is not managed by this client. It then performs the removal, follows it to completion (UC-006), and records the consequence.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server exists and provider access is valid.
  - DevOps is permitted by the provider to remove it.
- **Postconditions (success guarantee):**
  - The server is removed, or a cancellation is scheduled and its effective date is recorded.
  - The consequence shown to DevOps is recorded with the operation.

### Notes

- Proxmox VE destroys the server immediately (verified). Contabo sets a cancel date on the instance (verified); the rule for that date is not stated (open), so the confirmation shows the date the provider reports.
- Wording for delete versus cancel is open.
- Protection against accidental removal is open.
- Capability check follows [ADR-0002].

---

[ADR-0002]: ../../adr/adr-0002-provider-capability-model.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[25d8548]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/25d8548745b006859481203e636fc508f46f6957
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
