# Business Case

## Metadata
| Key | Value |
| --- | --- |
| ID | BC-001 |
| CrossReference | [SA-001] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | S02 | Spelled out CLI and JSONL on first use (RC-001 criterion 10) | [3876d67] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI (named by S01) | Stated strategic alignment, deadline and budget; accepted after RC-001 | pending |

---

## Executive Summary

IT teams that run servers at more than one provider manage each provider
through its own console and API, with different lifecycle semantics. This
project proposes iac-node-forge: one product that provisions and manages
servers at Proxmox VE and Contabo through their documented APIs. The product
is delivered as a Python command-line interface (CLI) and a WinUI 3
application, and both clients
support the same agreed use cases.

## Methodological and Standards Foundation

- Use-case-driven analysis after Larman, *Applying UML and Patterns*: use
  cases, System Sequence Diagrams, Domain Model, Operation Contracts.
- Quality criteria tagged with ISO/IEC 25010:2023 characteristics, reviewed
  against the SQA and QC framework mounted at `framework/`.
- Plan-first workflow: Business Case, Stakeholder Analysis, Project Plan,
  milestones, tasks, then code.

## Problem Statement

- Provisioning and day-to-day operation of servers differ per provider
  (Proxmox VE and Contabo), so the same task is done differently in each tool.
- Which servers exist, who created them and whether they match what was
  intended is not recorded in one place.
- Long-running provider operations (create, snapshot, cancel) have different
  status models, so failures are hard to see and recover from.

## Business Opportunity

One agreed set of use cases over several providers gives DevOps a single
vocabulary and workflow for server lifecycle work, and makes adding a further
provider a matter of implementing the same capabilities.

## Objectives

1. Provide agreed use cases for provider access, discovery, provisioning,
   bootstrap, operation tracking, inventory, power control, snapshots, drift
   detection, drift correction, deletion or cancellation, history, and
   backup and restore of server data.
2. Support these use cases for Proxmox VE and Contabo, with provider-specific
   behaviour made explicit through capability checks.
3. Deliver the same capabilities in a Python CLI and a WinUI 3 application,
   traceable use case to client.
4. Keep secrets out of the configuration files: they are prompted for and
   optionally cached in the operating system credential store.

## Scope

### In Scope

- Provider access and validation for Proxmox VE and Contabo.
- Server lifecycle use cases listed in Objectives (candidate set UC-01 to
  UC-19, to be confirmed in the Use Case Diagram).
- Display of servers not created by the tool, as not managed by this client.
- Backup and restore of server data: files between a server and the local PC,
  and whole-server backup where the provider supports it.
- Python 3.13 CLI and a WinUI 3 application (dotnet 10) distributed through
  the Microsoft Store.
- A JSON Lines (JSONL) configuration file per client.

### Out of Scope

- Tailscale or other VPN handling (later scope).
- Providers other than Proxmox VE and Contabo.
- Sharing one configuration file between the two clients.
- Storing tokens or passwords in project configuration.

## Expected Benefits

### Tangible Benefits

- One workflow replaces separate provider consoles for the agreed use cases.
- Operation history and drift reports make provider state auditable.

### Intangible Benefits

- A shared vocabulary for server lifecycle work.
- A foundation that can take further providers.

## Strategic Alignment

iac-node-forge supports TirSystem's goal of running its own infrastructure and
websites reliably and with little manual work, by giving DevOps one repeatable
way to provision and operate servers at the providers the company uses.

## Success Criteria

| # | Criterion | Target | Measure |
| --- | --- | --- | --- |
| 1 | Agreed Must use cases work against Proxmox VE | 100% of Must use cases | Acceptance review per use case |
| 2 | Agreed Must use cases work against Contabo | 100% of Must use cases | Acceptance review per use case |
| 3 | Same agreed use cases available in both clients | 100% traceable use case to client | Traceability matrix |
| 4 | No secret stored in configuration files | 0 secrets found | Review of config schema and test files |

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Provider API semantics differ more than assumed (for example Contabo task status, snapshots, cancel) | Use cases need provider-specific variants and rework | Capability model and verify each provider behaviour against its documentation before design |
| Managed state is held per client, so one client sees the other's servers as not managed | Drift reports differ between clients | Show "not managed by this client" explicitly; revisit a provider-side marker if it hurts |
| Provider API or credential model changes | Client breaks | Isolate providers behind one interface; validate access in UC-01 |
| Destructive actions on servers not created by the tool | Data loss or unwanted billing end | Extra confirmation for unmanaged servers, provider-specific consequence text |
| Store distribution constraints on the WinUI 3 app | Delay | Check Store requirements early in planning |
| The provider mock drifts from the real provider | Tests pass while real behaviour differs | Read-only smoke tests against live Contabo and integration tests against a Proxmox VE in a VM |
| Contabo create, update or delete is tested against the live account | Unplanned cost | Forbidden in automated tests; any real change is a manual, cost-approved acceptance by S01 |

## Assumptions

- Proxmox VE and Contabo documented APIs are available and stable
  (https://pve.proxmox.com/pve-docs/api-viewer/index.html,
  https://api.contabo.com/).
- The Product Owner accepts all artifacts; DevOps provides infrastructure and
  operational input. No other roles have acceptance authority.
- Windows Credential Manager (with Windows Hello PIN gating in WinUI 3) can
  hold provider secrets; the CLI must also run on non-Windows hosts with a
  platform keyring or ask on every run (to verify).
- The project starts as a prototype validated by its own use, not by external
  customers.
- S02 reviews artifacts authored by S01.

## Constraints

- English is the language of artifacts; established IT terminology is used.
- Python 3.13 for the CLI, dotnet 10 and WinUI 3 for the application.
- Source lives in two submodules: `iac-node-forge-py` and
  `iac-node-forge-winui3` on `git.tirsystem.com`.
- No code under `src/` or `tests/` before an accepted, reviewed milestone.
- No deadline and no budget limit: the work is done in the own time of S01 and S02.
  The baseline phase (MIL-001) is planned for 2026-10-14 to 2026-10-28, as confirmed
  by S01 on 2026-10-15.
- No create, update or delete against the live Contabo account in automated tests, because it costs money. Read-only calls are allowed.
- CI on Gitea cannot host a Proxmox VE VM (limited resources). CI uses a mock provider container; real Proxmox VE integration runs on a VM outside CI.

## Cost–Benefit Assessment

Qualitative, because there is no budget limit and no deadline (own time), so no
money figure can be stated.

| Costs | Benefits |
| --- | --- |
| Development effort for two clients and two provider integrations | One lifecycle workflow across providers |
| Maintenance when provider APIs change | Auditable operation history and drift detection |
| Verification of provider behaviour | Reuse of the use-case set for further providers |

## Stakeholders

| Stakeholder ID (SA) | Interest in this project |
| --- | --- |
| S01 | Defines scope and priorities, accepts all artifacts |
| S02 | Provides infrastructure, deployment and operational input; primary operator of the use cases |

## Recommendation

Proceed — the problem is real for the Product Owner and DevOps, and a first
milestone can be delimited and verified against one provider.

---

[SA-001]: ./stakeholder-analysis.md
[3876d67]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/3876d67f44db71c2dd2458e0a486da3437a192df
