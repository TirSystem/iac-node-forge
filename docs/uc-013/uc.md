# Review operation history and recover failed operations

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-013 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | pending |

---

**Format:** Brief

## Brief

DevOps reviews past operations with their outcome and cause. For a failed operation the system shows what was left behind at the provider and offers the safe ways to retry, resume or clean up, then follows the chosen action to completion (UC-006).

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - Operations have been recorded by earlier actions (UC-006).
- **Postconditions (success guarantee):**
  - DevOps knows what happened to past operations.
  - A failed operation is retried, resumed or cleaned up, or left unchanged by choice.

### Notes

- Operation history is kept in the client's own JSONL; how long it is kept is open.
- Which failures can safely be retried, for example a partially provisioned server, is open.
- Priority: Should.

---

[UCD-001]: ../use-case-diagram.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
