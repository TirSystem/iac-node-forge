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
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-017 | [d4593ae] |

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

- Both providers offer a graceful shutdown and a hard stop (verified); DevOps chooses, and the forced one needs confirmation.
- Servers not managed by this client need an extra confirmation.
- Capability check follows [ADR-0002].

---

[ADR-0002]: ../../adr/adr-0002-provider-capability-model.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
[d4593ae]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d4593aee3a0196cb5ced87130a3194ed20600c22
