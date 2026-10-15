# Detect drift

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-010 |
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

DevOps asks to compare the servers managed by this client with their desired configurations. The system reads the actual state from the providers, lists every difference found per server and property, and marks servers not managed by this client as such instead of as drift. Nothing is changed.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - Desired configurations exist for managed servers (UC-003).
  - Provider access is valid.
- **Postconditions (success guarantee):**
  - DevOps has a report of the differences between actual and desired state.
  - Nothing is changed at the provider.

### Notes

- Only properties both providers expose can be compared; which these are needs verification.
- Managed status is kept in the client's own JSONL, so a server provisioned by another client appears as not managed.
- Contabo has tags that could mark servers at the provider; not decided.
- Correcting drift is UC-011.
- Priority: Should.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
