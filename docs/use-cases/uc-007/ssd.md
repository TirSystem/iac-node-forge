# System Sequence Diagram: List and inspect servers

## Metadata
| Key | Value |
| --- | --- |
| ID | SSD-003 |
| CrossReference | [UC-007], [DM-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Initial version | [1f23e1f] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Alternate flows stated as out of scope (RC review)<br>Accepted after RC-036 | [de601dd] |

---

## Source Use Case

List and inspect servers ([UC-007]) — scenario: main success scenario.
Alternate flows (a provider cannot be reached, no provider is configured) are out of scope of this diagram.

## Diagram

```plantuml
@startuml
actor DevOps as A
participant ":System" as S
A -> S : listServers()
S --> A : serverSummaries
A -> S : inspectServer(configurationId, serverIdentifier)
S --> A : serverDetails
@enduml
```

## System Operations

| Step | Message | Parameters | Return | Use case step |
| --- | --- | --- | --- | --- |
| 1 | listServers | none (all configured providers) | list of server summaries: provider, state, size, addresses, managed or not | "shows each server with its provider, state, size and addresses, marking those not managed by this client" |
| 2 | inspectServer | configuration identifier, server identifier | server details | "lets DevOps open one server to see its provider details" |

## Lifecycle Notes

Both messages are read-only. A provider that cannot be reached is reported in the
result without hiding the servers of the other providers.

---

[UC-007]: ./uc.md
[DM-001]: ../../domain-model.md
[1f23e1f]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/1f23e1fc3e0a468ef08a393aa5fc50c87c4148cf
[de601dd]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/de601dd67be72a7d032de2146b4ec9cc8a213aec
