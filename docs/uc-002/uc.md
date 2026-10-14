# Discover capabilities and server options

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-002 |
| CrossReference | [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [25d8548] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | pending |

---

**Format:** Brief

## Brief

DevOps asks what a configured provider can do and offer. The system retrieves the available regions or nodes, images or templates, sizes or products, storage and network options, and the set of actions the provider and target support, and presents them.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - A provider configuration exists and its access is validated (UC-001).
- **Postconditions (success guarantee):**
  - The options and capabilities of the provider and target are known for this session.
  - Nothing is changed at the provider.

### Notes

- Capabilities follow [ADR-0002].
- Whether the result is cached, and for how long, is open.
- Proxmox VE exposes nodes, storage and storage content; Contabo exposes products, a fixed list of regions and images (verified). Further dependence on the target is open.

---

[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[25d8548]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/25d8548745b006859481203e636fc508f46f6957
