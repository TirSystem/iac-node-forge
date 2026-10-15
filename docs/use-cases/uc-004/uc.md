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
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-013 | [d4593ae] |

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
- Contabo creation requires a contract period of 1, 12 or 24 months; the cost confirmation must show it (verified).
- Proxmox VE needs a node and a VM identifier, which can be obtained from the cluster (verified).
- Preventing duplicate creation on retry is open.
- Bootstrap after provisioning is a separate use case (UC-005).

---

[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
[d4593ae]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d4593aee3a0196cb5ced87130a3194ed20600c22
