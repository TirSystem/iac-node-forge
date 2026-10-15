# Operation Contracts: Start, stop and restart a server

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-002 |
| CrossReference | [SSD-004], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-060 | [f91e283] |

---

## Contract: requestPowerAction

| Item | Value |
| --- | --- |
| Operation | `requestPowerAction(configuration: Text, serverIdentifier: Text, action: PowerAction, confirmation: Confirmation): PowerActionResult` |
| Traces to | `requestPowerAction` in [SSD-004] |
| Domain Model concepts | Operation, Server, ProviderConfiguration, ManagedServerRecord ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- A Server with `serverIdentifier` exists at that provider.
- The ProviderConfiguration's provider declares the Capability of `action`.
- The confirmation was given for this action and server; if the Server has no
  ManagedServerRecord, the retyped identifier equals `serverIdentifier`.
- The Server is not already in the state the action produces.

**Postconditions**

- An Operation instance was created with state `running` and the requested action.
- The Operation was associated with the Server and with the ProviderConfiguration.
- Exactly one power request was sent to the provider for this Operation.
- The Operation was persisted without any secret attribute.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The provider does not declare the Capability | Reported as unsupported; no request is sent and no Operation is created. |
| The confirmation is missing, refused or the identifier does not match | No request is sent and no Operation is created. |
| The Server is already in the requested state | Reported as already in that state; no request is sent and no Operation is created. |
| The provider rejects the request (authentication, 4xx, 5xx, unreachable) | The Operation is created with state `failed` and the reason as its detail; the request is not repeated. |
| The Server does not exist | Reported as not found; no request is sent. |

---

[SSD-004]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[f91e283]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/f91e283c8b54844b30c133036cb74d0cf4de80e0
