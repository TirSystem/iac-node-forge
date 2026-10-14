# Configure and validate provider access

## Metadata
| Key | Value |
| --- | --- |
| ID | UC-001 |
| CrossReference | [US-001], [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [25d8548] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Applied the provider API verification findings to the Notes | [7bde3e0] |

---

**Format:** Brief

## Brief

DevOps adds a provider configuration, giving its endpoint and, when asked, its credentials. The system checks with the provider that authentication works and that the account has the permissions the product needs, and reports the result. When it works, the configuration is saved without any secret, and the credentials may be cached in the operating system credential store if DevOps agrees.

- **Scope:** iac-node-forge
- **Level:** user-goal
- **Primary Actor:** DevOps
- **Preconditions:**
  - The provider endpoint is reachable from this machine.
  - DevOps has valid credentials for the provider.
- **Postconditions (success guarantee):**
  - A provider configuration is saved with a credential reference name and no secret.
  - DevOps knows whether access works, or why it does not.

### Notes

- Credential handling follows [ADR-0003].
- VPN access (Tailscale) to Proxmox VE is out of scope for now.
- Trust of a self-signed Proxmox VE certificate needs a decision (verify).
- Contabo needs four values (client ID, client secret, API user, API password) and a request ID on every call (verified); token lifetime is not stated and remains open.
- How a Proxmox VE API token is sent is not in the API viewer and remains open.

---

[ADR-0003]: ../adr/adr-0003-credential-storage.md
[US-001]: ../user-stories.md
[SA-001]: ../stakeholder-analysis.md
[25d8548]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/25d8548745b006859481203e636fc508f46f6957
[7bde3e0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/7bde3e007f21106df3dc4cf580c252e7e6996187
