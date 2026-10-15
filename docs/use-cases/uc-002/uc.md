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
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-011 | pending |

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

[ADR-0002]: ../../adr/adr-0002-provider-capability-model.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
