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
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | pending |

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
- Managed status is kept in the client's own JSONL, so another client may show the same server as not managed.
- Contabo lists the servers of the account through its API (as stated by the Product Owner).

---

[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
