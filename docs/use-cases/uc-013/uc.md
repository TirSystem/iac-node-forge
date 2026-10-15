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
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [673a8e4] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |

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
- Contabo keeps a history of actions and instances through audit endpoints (verified).
- Which failures can safely be retried, for example a partially provisioned server, is open.
- Priority: Should.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
