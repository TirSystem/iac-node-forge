# Define desired server configuration

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-003 |
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

DevOps describes the server wanted: a name, provider and target, size, image, access keys and bootstrap hints. The system checks the description against the discovered capabilities and options, reports anything unsupported, and stores the validated description as a named desired configuration.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - Capabilities and options of the chosen provider are known (UC-002).
- **Postconditions (success guarantee):**
  - A validated desired configuration is saved under a name.
  - Unsupported choices are reported and not saved as valid.

### Notes

- How much of a definition is provider-neutral and how much provider-specific is open.
- Whether a definition is a reusable template or describes one server is open.
- Stored in the client's JSONL; secrets are never included.

---

[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
