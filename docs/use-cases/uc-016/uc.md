# Back up server files to the local PC

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-016 |
| CrossReference | [UCD-001], [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [31933c9] |

---

**Format:** Brief

## Brief

DevOps chooses files or folders on a server and a destination on the local PC. The system connects to the server, copies the chosen data to the destination, verifies that the copy is complete, and reports what was copied.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The server is running and reachable, and DevOps can authenticate to it.
  - The destination on the local PC has room for the data.
- **Postconditions (success guarantee):**
  - The chosen data exists at the destination and is verified complete.
  - Nothing on the server is changed.

### Notes

- Provider-independent: works the same on Proxmox VE and Contabo because it uses access to the server itself, not the provider API.
- Which transfer method is used (SFTP or rsync) is open.
- Server access credentials follow [ADR-0003].
- Priority: Must.

---

[UCD-001]: ../../use-case-diagram.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[ADR-0003]: ../../adr/adr-0003-credential-storage.md
[31933c9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/31933c95a83dd3e114cc067cd907ddddb750b1bb
