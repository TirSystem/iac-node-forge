# Provision a server

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-004 |
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

DevOps asks to provision a server from a validated desired configuration. The system shows what will be created, including any cost or billing consequence the provider imposes, and asks for confirmation. After confirmation it submits the request to the provider, follows the operation to completion (UC-006), and records the new server as managed by this client.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - A validated desired configuration exists (UC-003).
  - Provider access is valid (UC-001).
- **Postconditions (success guarantee):**
  - The server exists at the provider and is recorded as managed by this client.
  - The operation and its outcome are recorded.
  - On failure the state left at the provider is reported.

### Notes

- Includes UC-006 (track long-running operations).
- Contabo billing starts at creation and needs an explicit cost confirmation (verify).
- Proxmox VE needs a node and a VM identifier (verify).
- Preventing duplicate creation on retry is open.
- Bootstrap after provisioning is a separate use case (UC-005).

---

[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[25d8548]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/25d8548745b006859481203e636fc508f46f6957
