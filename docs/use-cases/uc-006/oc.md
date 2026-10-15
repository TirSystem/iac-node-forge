# Operation Contracts: Track long-running operations

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-003 |
| CrossReference | [SSD-005], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-061 | [f91e283] |

---

`showOperation` changes no state and has no contract.

## Contract: followOperation

| Item | Value |
| --- | --- |
| Operation | `followOperation(operationId: OperationId, timeLimit: Duration): Operation` |
| Traces to | `followOperation` in [SSD-005] |
| Domain Model concepts | Operation, Server, ProviderConfiguration ([DM-001]) |

**Preconditions**

- An Operation with `operationId` exists and its state is `running`.
- The provider of the Operation's ProviderConfiguration can be asked for the Operation's
  state.

**Postconditions**

- The Operation's state was modified to `succeeded`, `failed` or `unknown`; it is never left
  `running` when the call returns.
- The Operation's end time was set.
- The Operation's detail was set to the cause when the provider gave one, or to the reason
  the outcome is unknown.
- The change was persisted without any secret attribute.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No Operation with `operationId` | Reported as not found. |
| The Operation is not `running` | Its recorded state is returned and nothing is changed. |
| The time limit passes before the provider reports an end | State `unknown` with the reason; the provider request is not repeated. |
| The provider cannot be reached | State `unknown` with the reason. |

---

[SSD-005]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
[f91e283]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/f91e283c8b54844b30c133036cb74d0cf4de80e0
