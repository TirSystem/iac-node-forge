# Operation Contracts: Configure and validate provider access

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-001 |
| CrossReference | [SSD-001], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | [1f23e1f] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`.

---

`validateAccess` changes no state and has no contract. Only the operation that changes
state is specified.

## Contract: saveProviderConfiguration

| Item | Value |
| --- | --- |
| Operation | `saveProviderConfiguration(providerKind: ProviderKind, address: Url, displayName: Text, cacheCredential: Boolean): ConfigurationId` |
| Traces to | `saveProviderConfiguration` in [SSD-001] |
| Domain Model concepts | ProviderConfiguration, Provider, CredentialReference ([DM-001]) |

**Preconditions**

- `validateAccess` returned a successful AccessResult for this providerKind, address and
  credentials in the current session.
- No ProviderConfiguration with this displayName exists.

**Postconditions**

- A ProviderConfiguration instance was created.
- The ProviderConfiguration was associated with the Provider of providerKind.
- The ProviderConfiguration was persisted without any secret attribute.
- If cacheCredential is true: a CredentialReference instance was created and associated
  with the ProviderConfiguration, and the credentials were placed in the platform
  credential store under that reference.
- The returned ConfigurationId identifies the new ProviderConfiguration.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No successful AccessResult in this session | The operation is rejected; nothing is created. |
| A ProviderConfiguration with this displayName exists | The operation is rejected; nothing is created. |
| The platform credential store is unavailable and cacheCredential is true | The ProviderConfiguration is created without a CredentialReference and the caller is told. |

---

[SSD-001]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[1f23e1f]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/1f23e1fc3e0a468ef08a393aa5fc50c87c4148cf
