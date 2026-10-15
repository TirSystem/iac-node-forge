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
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | AI (named by S01) | Accepted after RC-010 | [d4593ae] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Token header verified by the live run (RC-046) | [1c3c503] |

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
- A Proxmox VE API token is sent in the header `Authorization: PVEAPIToken=<token>`; this was shown by a live run on 2026-10-15 (verified).

---

[ADR-0003]: ../../adr/adr-0003-credential-storage.md
[US-001]: ../../user-stories.md
[SA-001]: ../../stakeholder-analysis.md
[d4593ae]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d4593aee3a0196cb5ced87130a3194ed20600c22
[1c3c503]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/1c3c503c273c8317e9d9e814b6ba0628270db1d0
