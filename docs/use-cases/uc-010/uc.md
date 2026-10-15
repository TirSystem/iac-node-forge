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
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Removed implementation detail from the Notes<br>Accepted after RC-019 | [d4593ae] |

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
- Managed status is kept in the client's own local records, so a server provisioned by another client appears as not managed.
- Contabo has tags that could mark servers at the provider; not decided.
- Correcting drift is UC-011.
- Priority: Should.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
[d4593ae]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d4593aee3a0196cb5ced87130a3194ed20600c22
