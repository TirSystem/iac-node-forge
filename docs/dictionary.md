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
| 2026-10-18 | Deprecated | Jens Tirsvad Nielsen | AI as stand-in for S02 | Added Removal kind and Consequence; Power action also names remove; Managed server can be ended (MIL-006)<br>Accepted after RC-085 | [6cdd351] |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Added Server access, Host key, Transfer, Manifest, Transfer report and Overwrite preview (MIL-007)<br>Accepted after RC-097 | [f05b1dd] |

---

## Purpose and Scope

Maps each Product Owner (PO) term to its professional IT term. PO language: English
(`en`), domain `it`. The dictionary covers the concepts of the domain model for provider
access, discovery, the listing of servers, power control, provisioning, removal and the transfer of
files (UC-001, UC-002, UC-003, UC-004, UC-006, UC-007, UC-008, UC-012, UC-016 and UC-017). A new concept
gets a row here in the same change as in the domain model.

## Dictionary

| PO term | Language | IT term | Definition | Used as PO term in | Used as IT term in |
| --- | --- | --- | --- | --- | --- |
| Provider | en | Provider | A company or platform that supplies servers and can be managed through an interface, such as Proxmox VE or Contabo. | DM, UC, US | OC, DCD, ERD |
| Provider configuration | en | ProviderConfiguration | The saved settings that connect this client to one provider: its address, a display name and the name of its credentials. | DM, UC, US | OC, DCD, ERD |
| Credential reference | en | CredentialReference | The name under which a secret is kept by the platform; the secret itself is never part of the configuration. | DM, UC, US | OC, DCD, ERD |
| Access check | en | AccessResult | The outcome of checking that the credentials work at the provider and carry the permissions the product needs. | DM, UC, US | OC, DCD, ERD |
| Capability | en | Capability | An action or option that a provider and target support, for example listing servers. | DM, UC, US | OC, DCD, ERD |
| Server option | en | ServerOption | A choice the provider offers when a server is created, such as a region, node, image or size. | DM, UC, US | OC, DCD, ERD |
| Server | en | Server | A machine, virtual or physical, that runs at a provider. | DM, UC, US | OC, DCD, ERD |
| Managed server | en | ManagedServerRecord | A server that this client has recorded as created or taken over by it, until a removal ends the record. | DM, UC, US | OC, DCD, ERD |
| Operation | en | Operation | One requested action at a provider that is followed until it ends. | DM, UC, US | OC, DCD, ERD |
| Power action | en | PowerAction | One of start, shutdown, stop or restart of a server, or provision (the creation of one) or remove (the ending of one); the kind of an operation. | DM, UC, US | OC, DCD, ERD |
| Desired configuration | en | DesiredConfiguration | A named, reusable description of the server wanted, checked against what the provider offers before it is saved as valid. | DM, UC, US | OC, DCD, ERD |
| Provider-specific value | en | ProviderValue | One named choice that only some providers need, such as a node, a storage, a region, a product or a contract period. | DM, UC, US | OC, DCD, ERD |
| Removal kind | en | RemovalKind | The way a provider ends a server, either destroyed now or cancelled with an effective date. | DM, UC, US | OC, DCD, ERD |
| Consequence | en | Consequence | The statement, shown before a removal is confirmed, of what the provider will do and what continues until then. | DM, UC, US | OC, DCD, ERD |
| Provision intent | en | ProvisionIntent | The record made before a creation request is sent, so that a retry does not create a second server. | DM, UC, US | OC, DCD, ERD |
| Server access | en | ServerAccess | The non-secret facts that this client keeps to reach the inside of one server: its host, port, user name and a hint about which identity to use. | DM, UC, US | OC, DCD, ERD |
| Host key | en | HostKey | The identity that a server shows when it is reached, with its fingerprint, which the user must trust before data is transferred. | DM, UC, US | OC, DCD, ERD |
| Transfer | en | Transfer | One copy of chosen files from a server to the local PC or from the local PC to a server, counted as done only when it is verified complete. | DM, UC, US | OC, DCD, ERD |
| Manifest | en | Manifest | The list of the files of a transfer with the path, size and checksum of each, made at the source and at the destination to compare them. | DM, UC, US | OC, DCD, ERD |
| Transfer report | en | TransferReport | The account of what a transfer did, including the verification result and any data it overwrote. | DM, UC, US | OC, DCD, ERD |
| Overwrite preview | en | OverwritePreview | The statement, made before a restore is confirmed, of the existing data on the server that it would replace. | DM, UC, US | OC, DCD, ERD |

## Rules

- The Domain Model, use cases and user stories use the PO term; the Operation
  Contract, Sequence Diagram, Design Class Diagram and ERD use the IT term.
- One IT term per PO term and one PO term per IT term; no synonyms.

---

[BC-001]: ./business-case.md
[SA-001]: ./stakeholder-analysis.md
[DM-001]: ./domain-model.md
[6cdd351]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/6cdd35154d6b48fceaa782699c9cbe88785b8247
[f05b1dd]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/f05b1dd98b3282a9b01ed2875fb706e6326af769
