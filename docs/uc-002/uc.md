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
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | pending |

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
- Which options depend on the target (Proxmox VE node and storage, Contabo product) needs verification.

---

[ADR-0002]: ../adr/adr-0002-provider-capability-model.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
