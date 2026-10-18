# Review of the Python code of MIL-006

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-091 |
| CrossReference | [MIL-006], [QC-PY-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | [77de1b9] |

---

## Artifact Under Review

- Instance reviewed: [MIL-006]
- Checklist used: [QC-PY-001]
- Scope: full review of the code of tasks 3 to 10 (iac-node-forge-py main through pull requests 21 (closed, its commit reached main through 22), 22 and 23)
- Language and domain: n/a (technical type)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI also wrote the code. The plan was accepted by S01 on 2026-10-18.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | Packages, modules, functions, variables, classes and constants follow PEP 8 casing (`snake_case`, `PascalCase`, `UPPER_SNAKE`) (Mandatory) | Pass | ruff `N` rules pass; snake_case modules, PascalCase classes, UPPER_SNAKE constants. |
| 2 | Names state purpose in the domain's language; no unexplained abbreviations, no single-letter names outside tiny scopes (Mandatory) | Pass | Names state purpose: `RemoveServer`, `ServerRemovalPort`, `RemovalKind`, `RemovalBlock`, `end_managed_server`; short names only in tiny scopes. |
| 3 | Code is produced by the project's formatter and passes its linter with no unexplained suppressions (Mandatory) | Pass | `ruff format --check` and `ruff check` pass; the `noqa` are `N802` and `A002` on handler names that `http.server` fixes (the mocks) and two `E501` on module paths that cannot be split, with a comment saying so. |
| 4 | Every function and method signature is type-annotated, including `-> None` (Mandatory) | Pass | `mypy --strict` passes on `src` and `tests` (169 files). |
| 5 | No bare `except:`, no swallowed exceptions; specific exceptions are raised and the cause is kept (`raise ... from`) (Mandatory) | Pass | No bare `except`; token and keyring errors are re-raised without the original text on purpose (`from None`) so no value leaks. |
| 6 | No mutable default arguments and no shadowed builtins (Mandatory) | Pass | No mutable default argument; no builtin shadowed. |
| 7 | Files, locks and connections are managed with context managers (Mandatory) | Pass | The HTTP client is used as a context manager; the temporary file in the store uses `with`. |
| 8 | Public modules, classes and functions have docstrings that say what, not how (Optional) | Pass | Public modules, classes and functions carry docstrings. |
| 9 | Logging uses `logging`, not `print`; no secrets or personal data in log output (Mandatory) | Pass | No `print` outside the CLI output module and no logging of values; tests show no credential in an operation record, the configuration file or an error text (Go criterion 6). |
| 10 | Classes and operations trace to the Design Class Diagram they implement; deviations are recorded (Mandatory) | Pass | Classes trace to DCD-001 revision 8, corrected to the built code in revision 9 (the next record); the deviations found were the name of the confirmation flag, who records the consequence, and the guard of `completeRemoval` against ending a newer server. |
| 11 | Tests exist for new behaviour, are named for the behaviour, and do not depend on order or the network (Mandatory) | Pass | 1142 tests collected for the default run and 22 integration tests deselected; the full run of the stacked branches gave 1140 passed and 2 skipped (28 end-to-end cases for removal, 57 removal contract cases, and the new unit tests); the live test skips without variables; named for behaviour; the mocks are in process. |
| 12 | Type checker runs in strict mode without errors; `Any` is justified in a comment (Optional) | Pass | Strict mode; `Any` appears only as the `_Json` alias in the two adapters, for decoded JSON. |
| 13 | Dependencies are declared and pinned in the project's dependency file, none unused (Optional) | Fail | Dependencies are still lower bounds only (`httpx`, `keyring`); no lock file. Optional; carried from RC-045. |
| 14 | Each piece of knowledge (a business rule, constant, format, validation or query) is defined in one place; code is merged only where it expresses the same knowledge, not where it merely looks alike (Mandatory) | Pass | Credential names and option kinds are defined once on `ProviderKind`; capability names once in `application/capabilities.py` (`remove_server` replaced the unused `delete_server`); the consequence text is produced once per provider by `consequence`; the refusal rules (running, already removed) are asked of the port through `removal_block` and tested nowhere by provider kind. |
| 15 | Imports point inward: business-rule modules import no framework, database, UI or delivery-mechanism code, and there are no import cycles (Mandatory) | Pass | `lint-imports`: 4 contracts kept; the adapter imports `application` and `domain` only; the auth URL is a composition-root parameter. |
| 16 | SOLID holds: a class or module has one reason to change; new behaviour is added by extension, not by editing a type test in several places; subclasses honour the contract of their base; protocols are narrow; high-level code depends on protocols or abstract types and receives its implementations (Mandatory) | Pass | The Strategy pattern holds: use cases do not test the provider kind; the resolver builds the adapter. |
| 17 | Source is laid out in the layers and folders of the clean architecture folder structure (`domain`, `application`, `infrastructure`, `presentation` packages under `src/`, and `unit`, `integration` and `e2e` under `tests/`), in `snake_case`, and imports between the layers point inward (Mandatory) | Pass | Layers unchanged under `src/iac_node_forge`; tests in `unit`, `contract`, `integration` and `e2e`. |
| 18 | File and folder names are English, contain no space and no character outside letters, digits, `-`, `_` and `.`, and follow the casing of the language for files (Mandatory) | Pass | All names English, no spaces, snake_case. |

## Overall Verdict

Go — every Mandatory criterion passes. The one failed criterion (13, Optional) is carried from RC-045. The Contabo cancellation, the shape of its answer and the effective-date rule have been run only against the mock; the removal of a virtual machine and of a running guest were not run live.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Pin or lock the Python dependencies | S01 | 2026-11-27 (MIL-006 decision date) |
| Independent confirmation by S02 of this review | S02 | 2026-11-27 (MIL-006 decision date) |

---

[MIL-006]: ../../milestones/mil-005-provisioning.md
[QC-PY-001]: ../../../framework/qc/code/qc-programming-python.md
[77de1b9]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/77de1b95c1cbfa8f502579b770c2f6bd538952ee
