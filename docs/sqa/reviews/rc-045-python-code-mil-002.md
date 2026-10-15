# Review of the Python code of MIL-002

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-045 |
| CrossReference | [MIL-002], [QC-PY-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | [6e1fc9a] |

---

## Artifact Under Review

- Instance reviewed: [MIL-002]
- Checklist used: [QC-PY-001]
- Scope: full review of the code of tasks 7 to 12 (iac-node-forge-py commits through c121551)
- Language and domain: n/a (technical type)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI also wrote the artifact. The plan was accepted by S01 on 2026-10-15.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | Packages, modules, functions, variables, classes and constants follow PEP 8 casing (`snake_case`, `PascalCase`, `UPPER_SNAKE`) (Mandatory) | Pass | ruff `N` rules pass; modules and functions snake_case, classes PascalCase, constants UPPER_SNAKE. |
| 2 | Names state purpose in the domain's language; no unexplained abbreviations, no single-letter names outside tiny scopes (Mandatory) | Pass | Names state purpose in the domain's words; short names appear only in tiny scopes. |
| 3 | Code is produced by the project's formatter and passes its linter with no unexplained suppressions (Mandatory) | Pass | `ruff format --check` and `ruff check` pass; the only suppression is none (no `noqa`). |
| 4 | Every function and method signature is type-annotated, including `-> None` (Mandatory) | Pass | `mypy --strict` passes on `src` and `tests` (86 files). |
| 5 | No bare `except:`, no swallowed exceptions; specific exceptions are raised and the cause is kept (`raise ... from`) (Mandatory) | Pass | No bare `except`; the one `except BaseException` in `_write_atomically` removes the temp file and re-raises; adapter errors use `from None` deliberately to avoid leaking a secret. |
| 6 | No mutable default arguments and no shadowed builtins (Mandatory) | Pass | No mutable default argument; no builtin is shadowed. |
| 7 | Files, locks and connections are managed with context managers (Mandatory) | Pass | Files use `os.fdopen` in a `with`; the HTTP client is used as a context manager. |
| 8 | Public modules, classes and functions have docstrings that say what, not how (Optional) | Pass | Public modules, classes and functions carry docstrings. |
| 9 | Logging uses `logging`, not `print`; no secrets or personal data in log output (Mandatory) | Pass | No `print` and no logging of secrets; output goes through one `output` module of the command line, and no secret is written. |
| 10 | Classes and operations trace to the Design Class Diagram they implement; deviations are recorded (Mandatory) | Pass | Classes trace to DCD-001; the deviations (ProviderResolver, DTOs, CredentialSource) are recorded in DCD-001 revision 2. |
| 11 | Tests exist for new behaviour, are named for the behaviour, and do not depend on order or the network (Mandatory) | Pass | 177 tests, named for behaviour, no order or network dependence (the mock is in process); one POSIX-only test is skipped on Windows and runs in CI. |
| 12 | Type checker runs in strict mode without errors; `Any` is justified in a comment (Optional) | Pass | Strict mode; the one `Any` (`type _Json = Any`) has a comment saying the provider JSON is untyped. |
| 13 | Dependencies are declared and pinned in the project's dependency file, none unused (Optional) | Fail | Dependencies are declared with lower bounds only and there is no lock file; none is unused. Optional. |
| 14 | Each piece of knowledge (a business rule, constant, format, validation or query) is defined in one place; code is merged only where it expresses the same knowledge, not where it merely looks alike (Mandatory) | Pass | Capability names are defined once in `application/capabilities.py`; the record shapes once in the configuration store. |
| 15 | Imports point inward: business-rule modules import no framework, database, UI or delivery-mechanism code, and there are no import cycles (Mandatory) | Pass | `lint-imports`: 4 contracts kept; the domain imports only the standard library. |
| 16 | SOLID holds: a class or module has one reason to change; new behaviour is added by extension, not by editing a type test in several places; subclasses honour the contract of their base; protocols are narrow; high-level code depends on protocols or abstract types and receives its implementations (Mandatory) | Pass | Ports are narrow protocols; use cases receive their ports; the adapter is replaced by a resolver in the composition root. |
| 17 | Source is laid out in the layers and folders of the clean architecture folder structure (`domain`, `application`, `infrastructure`, `presentation` packages under `src/`, and `unit`, `integration` and `e2e` under `tests/`), in `snake_case`, and imports between the layers point inward (Mandatory) | Pass | `domain`, `application`, `infrastructure`, `presentation` under `src/iac_node_forge`; tests in `unit`, `contract`, `integration` and `e2e` (`contract` is an addition for the mock). |
| 18 | File and folder names are English, contain no space and no character outside letters, digits, `-`, `_` and `.`, and follow the casing of the language for files (Mandatory) | Pass | All names are English, without spaces, in snake_case. |

## Overall Verdict

Go — every Mandatory criterion passes. The one failed criterion (13, Optional) has an action item. Reviewed at `iac-node-forge-py` main plus the open pull request 7 (`c121551`); a person's review of the pull requests remains.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Pin or lock the dependencies (a lock file or exact versions) in the Python repository | S01 | 2026-11-26 (MIL-002 decision date) |
| Independent confirmation by S02 of this review | S02 | 2026-11-26 (MIL-002 decision date) |

---

[MIL-002]: ../../milestones/mil-002-read-only-slice-proxmox-cli.md
[QC-PY-001]: ../../../framework/qc/code/qc-programming-python.md
[6e1fc9a]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/6e1fc9ab03ee8c75ad535849fee00964be1a3da4
