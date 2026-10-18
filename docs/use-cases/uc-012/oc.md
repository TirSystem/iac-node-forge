# Operation Contracts: Delete or cancel a server

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-006 |
| CrossReference | [SSD-008], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-087 | [6cdd351] |

---

## Contract: previewRemoval

| Item | Value |
| --- | --- |
| Operation | `previewRemoval(configuration: Text, serverIdentifier: Text): RemovalPreview` |
| Traces to | `previewRemoval` in [SSD-008] |
| Domain Model concepts | Server, Managed server, Removal kind, Consequence, Capability, Provider configuration ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- The provider declares the Capability `remove_server`.
- A Server with the identifier `serverIdentifier` exists at the provider.
- The Server can be removed now: it is not running where the provider requires it to be stopped
  first, and it is not already removed or cancelled.

**Postconditions**

- No instance was created, associated or modified, and no removal request, and no other write
  request, was sent.
- The result states the provider, the Server (identifier, name and state), whether the Server is
  a Managed server, the Removal kind of the provider, and the Consequence text: either that the
  server is destroyed now and its disks are released, or that a cancellation is requested, that the
  contract and its billing continue until an effective date, and that the date is the one the
  provider reports after the request.
- The result states that the identifier must be typed, and, when the Server is not a Managed
  server, that one more confirmation is required.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The provider does not declare the Capability | Reported as unsupported; the preview is not offered. |
| No such Server | Reported as not found; nothing is changed. |
| The Server is running where the provider requires it stopped | Reported as running, with the instruction to shut it down first; the Server is not stopped and the preview is not offered. |
| The Server is already removed or cancelled | Reported as already in that state, with the state; the preview is not offered. |
| The provider cannot be reached or rejects the read | Reported with the reason; nothing is changed. |

## Contract: requestRemoval

| Item | Value |
| --- | --- |
| Operation | `requestRemoval(configuration: Text, serverIdentifier: Text, confirmation: Confirmation): RemovalResult` |
| Traces to | `requestRemoval` in [SSD-008] |
| Domain Model concepts | Operation, Consequence, Removal kind, Server, Managed server, Provider configuration ([DM-001]) |

**Preconditions**

- The preconditions of `previewRemoval` hold.
- The confirmation was given for this ProviderConfiguration and Server, and the identifier typed
  equals the Server's identifier at the provider exactly (a display name or a prefix is not
  accepted).
- When the Server is not a Managed server, the confirmation also holds the identifier typed again
  for the unmanaged Server, equal to the Server's identifier.

**Postconditions**

- Exactly one removal request was sent to the provider for the Server, and no other write request.
  The Server was not stopped, and nothing but the Server was affected.
- An Operation instance was created with action `remove` and state `running`, associated with the
  ProviderConfiguration and the Server, with the Consequence text that was shown in the preview
  recorded with it.
- The Operation and its Consequence were persisted without any secret attribute.
- No Managed server was ended and no other record was changed.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The confirmation is missing or refused, or the extra confirmation of an unmanaged Server is missing | Reported as not confirmed; no Operation is created and no request is sent. |
| The identifier typed, or the one typed again, differs from the Server's identifier | Reported as identifier mismatch; no Operation is created and no request is sent. |
| The provider does not declare the Capability | Reported as unsupported; nothing is created and no request is sent. |
| No such Server | Reported as not found; nothing is created and no request is sent. |
| The Server is running where the provider requires it stopped | Reported as running, with the instruction to shut it down first; nothing is created and no request is sent. |
| The Server is already removed or cancelled | Reported as already in that state; nothing is created and no request is sent. |
| The provider rejects the request (authentication, permission, 4xx, 5xx) | The Operation is created with state `failed`, the reason as its detail and the Consequence recorded; the Managed server is not ended and the request is not repeated. |
| The request times out or the answer is lost | The Operation is created with state `unknown` and the Consequence recorded; the request is not repeated. |

## Contract: completeRemoval

| Item | Value |
| --- | --- |
| Operation | `completeRemoval(operationId: Text): RemovalResult` |
| Traces to | `completeRemoval` in [SSD-008] |
| Domain Model concepts | Operation, Consequence, Managed server, Server, Provider configuration ([DM-001]) |

**Preconditions**

- An Operation with action `remove` and identifier `operationId` exists.
- The Operation is not in state `running`.

**Postconditions**

- When the Operation is `succeeded`: if the Server is a Managed server, its ended date attribute
  was set and it was associated with the Operation that ended it, so it no longer counts as
  managed; the result states the Consequence recorded, the state left at the provider (for a
  cancellation the effective date the provider reports, recorded in the Operation's detail) and
  that the Managed server was ended. Nothing else was deleted or changed.
- When the Operation is `failed`: no Managed server was ended, and the result states the state
  left at the provider.
- When the Operation is `unknown`: nothing was changed and the result says so.
- Completing again an Operation whose Managed server is already ended changes nothing.
- The ended Managed server was persisted without any secret attribute.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No such Operation, or it is not a remove Operation | Reported as not found; nothing is changed. |
| The Operation is still `running` | Reported as not finished; nothing is changed. |
| The Operation `succeeded` but the provider reports no effective date for a cancellation | The Managed server is ended; the result says that no date was reported. |
| The provider cannot be reached to read the state left | The recording is done as above and the result says the state could not be read. |

---

[SSD-008]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[6cdd351]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/6cdd35154d6b48fceaa782699c9cbe88785b8247
