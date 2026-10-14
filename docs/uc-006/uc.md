# Track long-running operations

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-006 |
| CrossReference | [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [25d8548] |

---

**Format:** Brief

## Brief

When an action at a provider takes time, the system follows it to completion and keeps DevOps informed of its status, progress and outcome, recording the result so it can be reviewed later.

- **Scope:** iac-node-forge
- **Level:** subfunction
- **Primary Actor:** DevOps
- **Preconditions:**
  - An operation has been submitted to a provider.
- **Postconditions (success guarantee):**
  - The outcome (succeeded, failed or unknown) is recorded with its cause when known.

### Notes

- Proxmox VE has a task status model; Contabo may not, so status may have to be inferred (verify).
- Used by UC-004, UC-008, UC-009 and UC-012.
- Keeping operation history is UC-013.

---

[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[25d8548]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/25d8548745b006859481203e636fc508f46f6957
