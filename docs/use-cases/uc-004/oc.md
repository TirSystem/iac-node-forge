# Operation Contracts: Provision a server

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-005 |
| CrossReference | [SSD-007], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-075 | [aa570c0] |

---

## Contract: previewProvisioning

| Item | Value |
| --- | --- |
| Operation | `previewProvisioning(configuration: Text, desiredName: Text, serverName: Text): ProvisionPreview` |
| Traces to | `previewProvisioning` in [SSD-007] |
| Domain Model concepts | DesiredConfiguration, ProviderValue, ProvisionIntent, ProviderConfiguration, Server, Capability ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- A DesiredConfiguration named `desiredName` exists for it and is still valid against the
  ServerOptions the provider offers now.
- The provider declares the Capability `provision_server`.
- `serverName` is empty (the desired name is used) or a valid server name.

**Postconditions**

- No instance was created, associated or modified, and no create request was sent.
- The result states the provider, the target (node and storage, or region), the image, the size,
  the ProviderValues, the cost consequence (for Contabo the product and the contract period and
  that the account is committed to it) and the server name that would be created.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The DesiredConfiguration does not exist or is no longer valid | Reported as invalid with each problem; nothing is changed. |
| The provider does not declare the Capability | Reported as unsupported. |
| A Server named `serverName` exists at the provider | Reported as name exists; the preview is not offered. |
| A pending ProvisionIntent exists for the same server name and ProviderConfiguration | Reported as intent pending, with the operation identifier when known; the preview is not offered. |

## Contract: requestProvisioning

| Item | Value |
| --- | --- |
| Operation | `requestProvisioning(configuration: Text, desiredName: Text, serverName: Text, confirmation: Confirmation): ProvisionResult` |
| Traces to | `requestProvisioning` in [SSD-007] |
| Domain Model concepts | ProvisionIntent, DesiredConfiguration, ProviderValue, Operation, Server, ProviderConfiguration ([DM-001]) |

**Preconditions**

- The preconditions of `previewProvisioning` hold.
- The confirmation was given for this ProviderConfiguration, desired name and server name; for a
  provider that commits the account to a contract it covers the period shown in the preview.
- No Server named `serverName` exists at the provider.
- No ProvisionIntent in state `pending` exists for the same server name and ProviderConfiguration.

**Postconditions**

- A ProvisionIntent instance was created with state `pending`, with the server name, associated
  with the DesiredConfiguration, with a ProviderValue copy of the chosen values and, for Proxmox
  VE, the reserved identifier taken from the cluster; it was persisted before any create request
  was sent.
- Exactly one create request was sent to the provider for this ProvisionIntent.
- An Operation instance was created with action `provision` and state `running`, associated with
  the ProviderConfiguration and the ProvisionIntent, and with the Server when the provider
  answered with its identifier.
- The ProvisionIntent, the Operation and the ProviderValues were persisted without any secret
  attribute.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The confirmation is missing or refused | Reported as not confirmed; no ProvisionIntent or Operation is created and no request is sent. |
| The DesiredConfiguration does not exist or is no longer valid | Reported as invalid; nothing is created and no request is sent. |
| The provider does not declare the Capability | Reported as unsupported; nothing is created and no request is sent. |
| A Server with that name exists at the provider | Reported as name exists; no ProvisionIntent is created and no request is sent. |
| A pending ProvisionIntent for the same server name exists | Reported as intent pending; no request is sent. |
| The provider rejects the request (authentication, 4xx, 5xx) | The Operation is created with state `failed` and the reason as its detail, the ProvisionIntent ends, and the request is not repeated. |
| The request times out or the answer is lost | The Operation is created with state `unknown`, the ProvisionIntent stays `pending`, and the request is not repeated; a retry meets the pending ProvisionIntent. |

## Contract: completeProvisioning

| Item | Value |
| --- | --- |
| Operation | `completeProvisioning(operationId: Text): ProvisionResult` |
| Traces to | `completeProvisioning` in [SSD-007] |
| Domain Model concepts | Operation, ProvisionIntent, ManagedServerRecord, Server, ProviderConfiguration ([DM-001]) |

**Preconditions**

- An Operation with action `provision` and identifier `operationId` exists and is associated with
  a ProvisionIntent.
- The Operation is not in state `running`.

**Postconditions**

- When the Operation is `succeeded`: a ManagedServerRecord instance was created for the Server and
  associated with the ProviderConfiguration, and the ProvisionIntent ended.
- When the Operation is `failed`: no ManagedServerRecord was created, the ProvisionIntent ended,
  and the result states the Server left at the provider, or that none was found.
- When the Operation is `unknown`: nothing was created or changed and the ProvisionIntent stays
  `pending`; the result says so.
- The ManagedServerRecord was persisted without any secret attribute.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such Operation, or it is not a provision Operation | Reported as invalid; nothing is changed. |
| The Operation is still `running` | Reported as not finished; nothing is changed. |
| The Operation `succeeded` but no Server identifier is known | No ManagedServerRecord is created; reported as incomplete with the detail; the ProvisionIntent stays `pending`. |
| The provider cannot be reached to read the state left | The recording is done as above and the result says the state could not be read. |

---

[SSD-007]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[aa570c0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/aa570c0d24a2840723ff9a2db0e146999ae69381
