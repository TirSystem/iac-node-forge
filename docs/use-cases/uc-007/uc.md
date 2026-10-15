# List and inspect servers

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-007 |
| CrossReference | [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Removed implementation detail from the Notes<br>Accepted after RC-016 | pending |

---

**Format:** Brief

## Brief

DevOps asks to see the servers across the configured providers. The system shows each server with its provider, state, size and addresses, marking those not managed by this client, and lets DevOps open one server to see its provider details.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - At least one provider configuration with validated access exists (UC-001).
- **Postconditions (success guarantee):**
  - DevOps has a current view of the servers.
  - Nothing is changed at the provider.

### Notes

- Servers not created by this client are included and marked as not managed by this client.
- Managed status is kept in the client's own local records, so another client may show the same server as not managed.
- Contabo lists the servers of the account through its API (verified).

---

[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
