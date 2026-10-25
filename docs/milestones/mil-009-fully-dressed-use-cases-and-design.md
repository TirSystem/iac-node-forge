# Fully dressed use cases and the design

## Metadata
| Key | Value |
| --- | --- |
| ID | MIL-009 |
| CrossReference | [BC-001], [US-001], [MIL-008] |
| Language | en |
| Domain | it |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-25 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Accepted after RC-120 (autonomous mode, stand-in) | pending |

---

## Purpose

Bring the analysis and design documents up to the level the framework asks for before a second client is
written. Today all 19 use cases are `Brief`, only 12 have a system sequence diagram, 10 have operation
contracts, and there is no design sequence diagram (`SD`) at all, although the framework derives the design
class diagram from the sequence diagrams. The Python client was built from the briefs, the operation
contracts and decision records, and the design class diagram was corrected to the code afterwards. A WinUI 3
client in C# cannot be built the same way: it needs a design that is complete and does not depend on Python.
A Go means the Product Owner accepts that every use case is fully dressed, that every operation contract
is realised by a sequence diagram, that the design class diagram is derived from those diagrams and
traceable to them, and that the difference between the Python and the C# client is handled by a written
platform mapping and a design per client, not by two diverging designs of the core.

## Deliverable

- All 19 use cases in the `Fully Dressed` format: scope, level, primary actor, stakeholders and interests
  (with the stakeholder IDs), preconditions, postconditions, a numbered main success scenario, extensions and
  alternative flows, special requirements and business rules, and open issues. The open points that the
  built milestones settled (the transfer method, the previous version of overwritten data, the wording of a
  removal) are closed in the text.
- A system sequence diagram for every use case that lacks one, and an operation contract for every
  state-changing system operation that lacks one.
- A design sequence diagram (`SD`) for every operation contract, in the form of the framework: the diagram,
  the pattern annotations, the postcondition coverage and the responsibility check.
- A decision record for the platform-neutral design: what is neutral (the domain, the application layer,
  the ports and the behaviour), what is per client (the presentation and the adapters), and how names, data,
  errors and asynchrony map between Python and C#.
- The design class diagram rebuilt from the sequence diagrams: the neutral core, with every method traceable
  to a message of a sequence diagram, and a separate design for the Python client (the CLI and the adapters);
  the design of the WinUI 3 client is left to its own milestone.
- A comparison of the built Python code with the rebuilt design: every difference is either corrected in the
  documents or listed as a task for a later milestone.

## Go / No-Go Criteria

| # | Criterion (objectively checkable) | Go | No-Go |
| --- | --- | --- | --- |
| 1 | All 19 use cases have `Format: Fully Dressed` with every section of the framework, and a `Go` review record each | 19 of 19 | Any missing or not Go |
| 2 | Every use case has a system sequence diagram, and every state-changing system operation has an operation contract, each with a `Go` review record | All | Any missing or not Go |
| 3 | Every operation contract is realised by a block of a design sequence diagram with pattern annotations and full postcondition coverage, and each diagram has a `Go` review record | All | Any contract without a block, or a postcondition not covered |
| 4 | The decision record for the platform-neutral design and the platform mapping have a `Go` review record | Go | Not Go |
| 5 | Every method of the neutral design class diagram traces to a message of a design sequence diagram, and the traceability matrix shows it | All | Any method without a message |
| 6 | The design class diagram of the neutral core names no language, library or user interface type, and its diagrams render | Passes | Fails |
| 7 | The comparison of the Python code with the design is recorded, and every difference is closed or has an issue | All | Any difference unrecorded |
| 8 | The documents pass the framework's checks (`check-languages.sh`, diagram rendering) in Gitea CI | Pass | Fail |

## Dependencies

| Depends on | Reason |
| --- | --- |
| [MIL-008] accepted with a `Go` | The last Python slice; the comparison with the code needs the code to be stable |
| ADR-0002 and ADR-0006 to ADR-0010 accepted | The decisions the sequence diagrams and the platform mapping rest on |
| Framework v0.15.0 or later | The `SD`, `UC` and `DCD` types and their checklists |

## Traceability

| Business Case objective / KPI / user story | Reference |
| --- | --- |
| Objective 1: the agreed use cases | [BC-001] Objectives |
| Objective 3: the same capabilities in every client | [BC-001] Objectives |
| All user stories of [US-001] | [US-001] |

## Ownership

| Role | Stakeholder ID (SA) |
| --- | --- |
| Owner | S01 |
| Approving reviewer | S02 |

## Target Date

2027-02-12 — about eight weeks from 2026-12-21, an assumption to be confirmed by S01. The Business Case
states no deadline, so there is no constraint to conflict with.

## Tasks

| # | Task | Summary | Needs its own Use Case/User Story? | Reference |
| --- | --- | --- | --- | --- |
| 1 | Decide the platform-neutral design and the platform mapping | Record in an ADR what is neutral and what is per client, the mapping of names, immutable data, interfaces, errors and asynchrony between Python and C#, where the per-client designs live, and how the shared contract tests keep the clients equal. | No | ADR |
| 2 | Fully dress the use cases UC-001 to UC-008 | Rewrite the use cases of the read side, the setup and the first actions in the full format, closing the points the built milestones settled. | No | UC |
| 3 | Fully dress the use cases UC-009 to UC-015 | Rewrite the use cases that are not built yet (snapshots, drift, history, keys and secrets, resize and rescue, and the bootstrap), with their open issues stated. | No | UC |
| 4 | Fully dress the use cases UC-016 to UC-019 | Rewrite the file and whole-server backup and restore use cases, closing the points the two milestones settled. | No | UC |
| 5 | Complete the system sequence diagrams and the operation contracts | Add the system sequence diagrams and the operation contracts that are missing, and check the existing ones against the fully dressed text. | No | SSD, OC |
| 6 | Design sequence diagrams for UC-001 to UC-008 | One block per operation contract of the built read side, setup and first actions: diagram, pattern annotations, postcondition coverage and responsibility check. | No | SD |
| 7 | Design sequence diagrams for UC-012 and UC-016 to UC-019 | The same for removal, the file backup and restore and the whole-server backup and restore. | No | SD |
| 8 | Design sequence diagrams for the use cases not built yet | The same for UC-005, UC-009 to UC-011 and UC-013 to UC-015, as far as their contracts are settled. | No | SD |
| 9 | Rebuild the design class diagram | Derive the neutral core diagram from the sequence diagrams, trace every method to a message, and move the Python presentation and adapters into the design of the Python client. | No | DCD |
| 10 | Compare the Python code with the design | List every difference between the built code and the rebuilt design; close each in the documents or open an issue for a later milestone. | No | |
| 11 | Review the artifacts | Review records for every use case, sequence diagram, contract, the decision record and the design class diagrams, and update the traceability matrix. | No | |

---

[BC-001]: ../business-case.md
[US-001]: ../user-stories.md
[MIL-008]: ./mil-008-whole-server-backup-and-restore.md
