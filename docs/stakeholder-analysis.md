# Stakeholder Analysis

## Metadata
| Key | Value |
| --- | --- |
| ID | SA-001 |
| CrossReference | [BC-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-14 | Proposed | Jens Tirsvad Nielsen | S02 | Initial version | pending |

---

## Purpose

Identify who has an interest in or authority over iac-node-forge, so every
artifact can cite exact stakeholder IDs for ownership, review and acceptance.
The method is a power/interest grid with concerns mapped to FURPS+.

## Stakeholder Summary Table

| ID | Name | Role/Title | Organization | Power Level | Interest Level | Quadrant | Primary Concern (Business Language) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| S01 | Jens Tirsvad Nielsen | Product Owner | TirSystem | HIGH | HIGH | Manage Closely | The product delivers the agreed use cases on both providers and both clients, and he can accept each artifact. |
| S02 | Michael Kragh | DevOps | TirSystem | MEDIUM | HIGH | Keep Satisfied | Servers can be provisioned, operated and recovered reliably, and deployment and operation fit his practice. |

## Power/Interest Classification Rationale

- **Manage Closely (S01):** the only stakeholder with acceptance authority;
  decides scope, priorities and every acceptance.
- **Keep Satisfied (S02):** provides DevOps, infrastructure and operational
  input and is the primary operator of the use cases, but has no acceptance
  authority. Interest is high; power is rated MEDIUM because his input shapes
  the design without deciding acceptance. S02 reviews artifacts authored by
  S01 (see Sign-Off).

No other stakeholder is assigned. Roles not backed by a named person (for
example end users of the Store application) are not stakeholders until the
Product Owner assigns a person.

## Primary Concerns and FURPS+ Mapping

| ID | Concern | FURPS+ attribute |
| --- | --- | --- |
| S01 | Same agreed capabilities in the Python CLI and the WinUI 3 application | Functionality |
| S01 | Provider differences (Proxmox VE, Contabo) are explicit, not hidden | Functionality |
| S01 | Secrets never stored in configuration files | Functionality (security) |
| S02 | Operations are visible, recoverable and repeatable | Reliability |
| S02 | Provider calls and long-running operations behave predictably | Reliability, Performance |
| S02 | CLI usable on hosts without Windows | Supportability |

## Communication Requirements

| ID | Channel | Frequency | Deliverable | Phase / Milestone |
| --- | --- | --- | --- | --- |
| S01 | Chat session with the AI assistant | Per artifact | Draft for acceptance | Every milestone |
| S02 | Git host review request | Per artifact needing review | Review record (`RC-*`) | Every milestone |

## Conflicting Interests and Mitigations

| Conflict | Stakeholders | Mitigation |
| --- | --- | --- |
| Product Owner acceptance versus independent review: S01 authors and accepts, and S02 is the only other stakeholder | S01, S02 | S02 reviews artifacts authored by S01; S01 accepts. Review records state who reviewed. |

## Traceability Analysis

### Business Goal Alignment

| Stakeholder | Concern | Business Case objective |
| --- | --- | --- |
| S01 | Same capabilities in both clients | [BC-001] Objective 3 |
| S01 | Provider differences explicit | [BC-001] Objective 2 |
| S01 | No secrets in config | [BC-001] Objective 4 |
| S02 | Operable and recoverable servers | [BC-001] Objective 1 |

## Sign-Off

| ID | Role | Status |
| --- | --- | --- |
| S01 | Accepts | pending |
| S02 | Reviews | pending |

---

[BC-001]: ./business-case.md
