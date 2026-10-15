# Domain Dictionary (PO and IT terms)

## Metadata
| Key | Value |
| --- | --- |
| ID | DICT-001 |
| CrossReference | [BC-001], [SA-001], [DM-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version, terms of the read-only slice (MIL-002) | pending |

---

## Purpose and Scope

Maps each Product Owner (PO) term to its professional IT term. PO language: English
(`en`), domain `it`. The dictionary covers the concepts of the domain model for provider
access, discovery and the listing of servers (UC-001, UC-002 and UC-007). A new concept
gets a row here in the same change as in the domain model.

## Dictionary

| PO term | Language | IT term | Definition | Used as PO term in | Used as IT term in |
| --- | --- | --- | --- | --- | --- |
| Provider | en | Provider | A company or platform that supplies servers and can be managed through an interface, such as Proxmox VE or Contabo. | DM, UC, US | OC, SD, DCD, ERD |
| Provider configuration | en | ProviderConfiguration | The saved settings that connect this client to one provider: its address, a display name and the name of its credentials. | DM, UC, US | OC, SD, DCD, ERD |
| Credential reference | en | CredentialReference | The name under which a secret is kept by the platform; the secret itself is never part of the configuration. | DM, UC, US | OC, SD, DCD, ERD |
| Access check | en | AccessResult | The outcome of checking that the credentials work at the provider and carry the permissions the product needs. | DM, UC, US | OC, SD, DCD, ERD |
| Capability | en | Capability | An action or option that a provider and target support, for example listing servers. | DM, UC, US | OC, SD, DCD, ERD |
| Server option | en | ServerOption | A choice the provider offers when a server is created, such as a region, node, image or size. | DM, UC, US | OC, SD, DCD, ERD |
| Server | en | Server | A machine, virtual or physical, that runs at a provider. | DM, UC, US | OC, SD, DCD, ERD |
| Managed server | en | ManagedServerRecord | A server that this client has recorded as created or taken over by it. | DM, UC, US | OC, SD, DCD, ERD |

## Rules

- The Domain Model, use cases and user stories use the PO term; the Operation
  Contract, Sequence Diagram, Design Class Diagram and ERD use the IT term.
- One IT term per PO term and one PO term per IT term; no synonyms.

---

[BC-001]: ./business-case.md
[SA-001]: ./stakeholder-analysis.md
[DM-001]: ./domain-model.md
