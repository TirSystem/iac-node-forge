# Review of the Python code of MIL-003

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-051 |
| CrossReference | [MIL-003], [QC-PY-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-003]
- Checklist used: [QC-PY-001]
- Scope: full review of the code of tasks 3 to 9 (iac-node-forge-py main through pull request 11, and pull request 12)
- Language and domain: n/a (technical type)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI also wrote the code. The plan was accepted by S01 on 2026-10-15.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | Packages, modules, functions, variables, classes and constants follow PEP 8 casing (`snake_case`, `PascalCase`, `UPPER_SNAKE`) (Mandatory) | Pass | ruff `N` rules pass; snake_case modules, PascalCase classes, UPPER_SNAKE constants. |
| 2 | Names state purpose in the domain's language; no unexplained abbreviations, no single-letter names outside tiny scopes (Mandatory) | Pass | Names state purpose: `ContaboProvider`, `ProviderUnderTest`, `credential_names`; short names only in tiny scopes. |
| 3 | Code is produced by the project's formatter and passes its linter with no unexplained suppressions (Mandatory) | Pass | `ruff format --check` and `ruff check` pass; no `noqa`. |
| 4 | Every function and method signature is type-annotated, including `-> None` (Mandatory) | Pass | `mypy --strict` passes on `src` and `tests` (98 files). |
| 5 | No bare `except:`, no swallowed exceptions; specific exceptions are raised and the cause is kept (`raise ... from`) (Mandatory) | Pass | No bare `except`; token and keyring errors are re-raised without the original text on purpose (`from None`) so no value leaks. |
| 6 | No mutable default arguments and no shadowed builtins (Mandatory) | Pass | No mutable default argument; no builtin shadowed. |
| 7 | Files, locks and connections are managed with context managers (Mandatory) | Pass | The HTTP client is used as a context manager; the temporary file in the store uses `with`. |
| 8 | Public modules, classes and functions have docstrings that say what, not how (Optional) | Pass | Public modules, classes and functions carry docstrings. |
| 9 | Logging uses `logging`, not `print`; no secrets or personal data in log output (Mandatory) | Pass | No `print` outside the CLI output module and no logging of values; the live tests prove no value in `caplog`. |
| 10 | Classes and operations trace to the Design Class Diagram they implement; deviations are recorded (Mandatory) | Pass | Classes trace to DCD-001 revision 3; deviations (the `_http.py` helper, page-limit error) are recorded in the pull requests. |
| 11 | Tests exist for new behaviour, are named for the behaviour, and do not depend on order or the network (Mandatory) | Pass | 279 tests plus 9 live tests (skipped without credentials); named for behaviour; the mocks are in process. |
| 12 | Type checker runs in strict mode without errors; `Any` is justified in a comment (Optional) | Pass | Strict mode; the one `Any` in the Proxmox adapter has a comment; the Contabo adapter uses typed JSON narrowing. |
| 13 | Dependencies are declared and pinned in the project's dependency file, none unused (Optional) | Fail | Dependencies are still lower bounds only (`httpx`, `keyring`); no lock file. Optional; carried from RC-045. |
| 14 | Each piece of knowledge (a business rule, constant, format, validation or query) is defined in one place; code is merged only where it expresses the same knowledge, not where it merely looks alike (Mandatory) | Pass | Credential names, option kinds and the default address are defined once on `ProviderKind`; capability names once in `application/capabilities.py`; the shared HTTP helpers once in `_http.py`. |
| 15 | Imports point inward: business-rule modules import no framework, database, UI or delivery-mechanism code, and there are no import cycles (Mandatory) | Pass | `lint-imports`: 4 contracts kept; the adapter imports `application` and `domain` only; the auth URL is a composition-root parameter. |
| 16 | SOLID holds: a class or module has one reason to change; new behaviour is added by extension, not by editing a type test in several places; subclasses honour the contract of their base; protocols are narrow; high-level code depends on protocols or abstract types and receives its implementations (Mandatory) | Pass | The Strategy pattern holds: use cases do not test the provider kind; the resolver builds the adapter. |
| 17 | Source is laid out in the layers and folders of the clean architecture folder structure (`domain`, `application`, `infrastructure`, `presentation` packages under `src/`, and `unit`, `integration` and `e2e` under `tests/`), in `snake_case`, and imports between the layers point inward (Mandatory) | Pass | Layers unchanged under `src/iac_node_forge`; tests in `unit`, `contract`, `integration` and `e2e`. |
| 18 | File and folder names are English, contain no space and no character outside letters, digits, `-`, `_` and `.`, and follow the casing of the language for files (Mandatory) | Pass | All names English, no spaces, snake_case. |

## Overall Verdict

Go — every Mandatory criterion passes. The one failed criterion (13, Optional) has an action item carried from RC-045. Pull request 12 (the live tests) and the live run itself are not part of what was run against a real service.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Pin or lock the Python dependencies | S01 | 2026-11-13 (MIL-003 decision date) |
| Independent confirmation by S02 of this review | S02 | 2026-11-13 (MIL-003 decision date) |

---

[MIL-003]: ../../milestones/mil-003-contabo-read-only-adapter.md
[QC-PY-001]: ../../../framework/qc/code/qc-programming-python.md
