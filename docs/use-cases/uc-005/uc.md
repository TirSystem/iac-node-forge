# Bootstrap a server after provisioning

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-005 |
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

After a server has been provisioned, DevOps asks for it to be made usable. The system waits until the server can be reached, applies the configured first-boot setup such as access keys and base configuration, follows the operation to completion, and reports whether the server is ready.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server exists at the provider and is recorded as managed by this client (UC-004).
  - A bootstrap configuration is part of the desired configuration.
- **Postconditions (success guarantee):**
  - The server is reachable and configured as described, or the failure and the state left are reported.
  - The outcome is recorded with the operation.

### Notes

- Extends UC-004; optional.
- Contabo accepts cloud-init user data at creation and reinstall (verified). Proxmox VE has cloud-init configuration endpoints; whether the template has a cloud-init drive depends on the template (open).
- Which first-boot mechanism and script runner are used is open.
- Priority: Should.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
