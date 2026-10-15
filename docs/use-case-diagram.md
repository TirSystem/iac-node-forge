# Use Case Diagram

## Metadata
| Key | Value |
| --- | --- |
| ID | UCD-001 |
| CrossReference | [SA-001], [BC-001], [US-001], [UC-001], [UC-002], [UC-003], [UC-004], [UC-005], [UC-006], [UC-007], [UC-008], [UC-009], [UC-010], [UC-011], [UC-012], [UC-013], [UC-014], [UC-015], [UC-016], [UC-017], [UC-018], [UC-019] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Linked the use case documents UC-005, UC-009 to UC-011 and UC-013 to UC-015 | [673a8e4] |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Added backup and restore use cases UC-016 to UC-019 and the managed server actor | [31933c9] |

---

## Purpose and Scope

The diagram shows the goals DevOps pursues with iac-node-forge and the
external systems the product calls to reach them. The system boundary is the
product as a whole: the Python CLI and the WinUI 3 application are two
clients for the same use cases and are not drawn as separate systems.

In scope are the candidate use cases UC-001 to UC-019 agreed with the Product
Owner for [BC-001]. Tailscale or other VPN handling is out of scope for now.

All use cases UC-001 to UC-019 have Brief documents.

## Diagram

```plantuml
@startuml
left to right direction
skinparam packageStyle rectangle

actor "DevOps" as DevOps <<Actor>>
actor "Proxmox VE" as PVE <<System>>
actor "Contabo" as CON <<System>>
actor "OS Credential Store" as CRED <<System>>
actor "Managed server (SSH)" as SRV <<System>>

rectangle "iac-node-forge" <<System>> {
  usecase "Configure and validate provider access" as UC01
  usecase "Discover capabilities and server options" as UC02
  usecase "Define desired server configuration" as UC03
  usecase "Provision a server" as UC04
  usecase "Bootstrap a server after provisioning" as UC05
  usecase "Track long-running operations" as UC06
  usecase "List and inspect servers" as UC07
  usecase "Start, stop and restart a server" as UC08
  usecase "Manage snapshots" as UC09
  usecase "Detect drift" as UC10
  usecase "Correct drift" as UC11
  usecase "Delete or cancel a server" as UC12
  usecase "Review operation history and recover failed operations" as UC13
  usecase "Manage SSH keys and secrets" as UC14
  usecase "Resize, reinstall or rescue a server" as UC15
  usecase "Back up server files to the local PC" as UC16
  usecase "Restore files from the local PC to the server" as UC17
  usecase "Back up a whole server" as UC18
  usecase "Restore a whole server from a backup" as UC19
}

DevOps --> UC01
DevOps --> UC02
DevOps --> UC03
DevOps --> UC04
DevOps --> UC07
DevOps --> UC08
DevOps --> UC09
DevOps --> UC10
DevOps --> UC12
DevOps --> UC13
DevOps --> UC14
DevOps --> UC15
DevOps --> UC16
DevOps --> UC17
DevOps --> UC18
DevOps --> UC19

UC04 ..> UC06 : <<include>>
UC08 ..> UC06 : <<include>>
UC09 ..> UC06 : <<include>>
UC12 ..> UC06 : <<include>>
UC18 ..> UC06 : <<include>>
UC19 ..> UC06 : <<include>>
UC05 ..> UC04 : <<extend>>
UC11 ..> UC10 : <<extend>>

UC01 --> CRED
UC01 --> PVE
UC01 --> CON
UC02 --> PVE
UC02 --> CON
UC04 --> PVE
UC04 --> CON
UC06 --> PVE
UC06 --> CON
UC07 --> PVE
UC07 --> CON
UC08 --> PVE
UC08 --> CON
UC09 --> PVE
UC09 --> CON
UC12 --> PVE
UC12 --> CON
UC16 --> SRV
UC17 --> SRV
UC18 --> PVE
UC18 --> CON
UC19 --> PVE
UC19 --> CON
@enduml
```

The diagram has not been rendered yet; check it with
`framework/scripts/render-diagrams.sh` before review.

## Actor Table

| Actor | Stereotype | Stakeholder ID (SA) | Goals (use cases) |
| --- | --- | --- | --- |
| DevOps | `<<Actor>>` (primary) | S02 | UC-001, UC-002, UC-003, UC-004, UC-007, UC-008, UC-009, UC-010, UC-012, UC-013, UC-014, UC-015, UC-016, UC-017, UC-018, UC-019 |
| Proxmox VE | `<<System>>` (secondary) | none, external system | UC-001, UC-002, UC-004, UC-006, UC-007, UC-008, UC-009, UC-012, UC-018, UC-019 |
| Contabo | `<<System>>` (secondary) | none, external system | UC-001, UC-002, UC-004, UC-006, UC-007, UC-008, UC-009, UC-012, UC-018, UC-019 |
| OS Credential Store | `<<System>>` (secondary) | none, external system | UC-001 |
| Managed server (SSH) | `<<System>>` (secondary) | none, external system | UC-016, UC-017 |

The Product Owner (S01) has no use case of his own: he accepts artifacts and
does not operate the product, so he is not drawn as an actor.

## Use Case Table

| Use Case | Actor(s) | Goal | Document |
| --- | --- | --- | --- |
| UC-001 Configure and validate provider access | DevOps | Know that a provider can be used | [UC-001] |
| UC-002 Discover capabilities and server options | DevOps | See what a provider and target can do | [UC-002] |
| UC-003 Define desired server configuration | DevOps | Describe the server wanted | [UC-003] |
| UC-004 Provision a server | DevOps | Get a running server from a definition | [UC-004] |
| UC-005 Bootstrap a server after provisioning | DevOps | Make a new server usable | [UC-005] |
| UC-006 Track long-running operations | DevOps (via included use cases) | Know the outcome of an operation | [UC-006] |
| UC-007 List and inspect servers | DevOps | See what exists and what this client manages | [UC-007] |
| UC-008 Start, stop and restart a server | DevOps | Control power state | [UC-008] |
| UC-009 Manage snapshots | DevOps | Keep and restore point-in-time copies | [UC-009] |
| UC-010 Detect drift | DevOps | See where actual state differs from desired | [UC-010] |
| UC-011 Correct drift | DevOps (via detect drift) | Bring actual state back to desired | [UC-011] |
| UC-012 Delete or cancel a server | DevOps | Remove a server knowing the consequence | [UC-012] |
| UC-013 Review operation history and recover failed operations | DevOps | Understand and fix failures | [UC-013] |
| UC-014 Manage SSH keys and secrets | DevOps | Provide access keys to servers | [UC-014] |
| UC-015 Resize, reinstall or rescue a server | DevOps | Change an existing server | [UC-015] |
| UC-016 Back up server files to the local PC | DevOps | Keep a copy of server data locally | [UC-016] |
| UC-017 Restore files from the local PC to the server | DevOps | Put data on the server | [UC-017] |
| UC-018 Back up a whole server | DevOps | Be able to recover a whole server | [UC-018] |
| UC-019 Restore a whole server from a backup | DevOps | Recover a whole server | [UC-019] |

## Relationships

| Relationship | Justification |
| --- | --- |
| UC-004 `<<include>>` UC-006 | Provisioning always follows its operation to completion. |
| UC-008 `<<include>>` UC-006 | Power actions always follow their operation to completion. |
| UC-009 `<<include>>` UC-006 | Snapshot actions are long-running at the providers and are always followed. |
| UC-012 `<<include>>` UC-006 | Removal always follows its operation to completion. |
| UC-018 `<<include>>` UC-006 | A whole-server backup is long-running and is always followed. |
| UC-019 `<<include>>` UC-006 | A whole-server restore is long-running and is always followed. |
| UC-005 `<<extend>>` UC-004 | Bootstrap is optional and happens only after a server has been provisioned. |
| UC-011 `<<extend>>` UC-010 | Correction is offered only when drift has been detected. |

---

[SA-001]: ./stakeholder-analysis.md
[BC-001]: ./business-case.md
[US-001]: ./user-stories.md
[UC-001]: ./uc-001/uc.md
[UC-002]: ./uc-002/uc.md
[UC-003]: ./uc-003/uc.md
[UC-004]: ./uc-004/uc.md
[UC-005]: ./uc-005/uc.md
[UC-006]: ./uc-006/uc.md
[UC-007]: ./uc-007/uc.md
[UC-008]: ./uc-008/uc.md
[UC-009]: ./uc-009/uc.md
[UC-010]: ./uc-010/uc.md
[UC-011]: ./uc-011/uc.md
[UC-012]: ./uc-012/uc.md
[UC-013]: ./uc-013/uc.md
[UC-014]: ./uc-014/uc.md
[UC-015]: ./uc-015/uc.md
[d6c95d9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/d6c95d9d3c454f4927e0639f96e0338880dca5fb
[673a8e4]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/673a8e48834f9cd28ea18ad4374945b70e5aa03a
[UC-016]: ./uc-016/uc.md
[UC-017]: ./uc-017/uc.md
[UC-018]: ./uc-018/uc.md
[UC-019]: ./uc-019/uc.md
[31933c9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/31933c95a83dd3e114cc067cd907ddddb750b1bb
