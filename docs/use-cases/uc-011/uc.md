# Correct drift

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-011 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Deprecated | Jens Tirsvad Nielsen | S02 | Initial version | [673a8e4] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-020 | [d4593ae] |

---

**Format:** Brief

## Brief

After drift has been detected, DevOps chooses which differences to correct. The system shows what each correction would change at the provider, asks for confirmation, applies the chosen corrections, follows them to completion (UC-006), and reports the new state.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - Drift has been detected and reported (UC-010).
  - Provider access is valid.
- **Postconditions (success guarantee):**
  - The chosen differences are corrected, or the failure and the state left are reported.
  - Differences not chosen are left unchanged.

### Notes

- Extends UC-010; optional.
- Which differences can be corrected without recreating a server is provider-specific and needs verification.
- Corrections that are destructive follow the confirmation rules of UC-012.
- Priority: Could.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
[d4593ae]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d4593aee3a0196cb5ced87130a3194ed20600c22
