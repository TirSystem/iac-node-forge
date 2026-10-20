# Review of the Python code of MIL-007

## Metadata
| Key | Value |
| --- | --- |
| ID | RC-107 |
| CrossReference | [MIL-007], [QC-PY-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-20 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version; accepted in autonomous mode | pending |

---

## Artifact Under Review

- Instance reviewed: [MIL-007]
- Checklist used: [QC-PY-001]
- Scope: full review of the code of tasks 3 to 9 (iac-node-forge-py main through pull request 24, and pull requests 25 and 26)
- Language and domain: n/a (technical type)
- Language reviewer: none
- Mode: autonomous, not independent. The reviewer is `AI as stand-in for S02`; the AI also wrote the code. The plan was accepted by S01 on 2026-10-20.

## Checklist Results

| # | Criterion | Status | Evidence/Notes |
| --- | --- | --- | --- |
| 1 | Packages, modules, functions, variables, classes and constants follow PEP 8 casing (`snake_case`, `PascalCase`, `UPPER_SNAKE`) (Mandatory) | Pass | ruff `N` rules pass; snake_case modules, PascalCase classes, UPPER_SNAKE constants. |
| 2 | Names state purpose in the domain's language; no unexplained abbreviations, no single-letter names outside tiny scopes (Mandatory) | Pass | Names state purpose: `BackUpFiles`, `RestoreFiles`, `OpenSshCommands`, `RemoteReadPort`, `HostKeyStanding`; short names only in tiny scopes. |
| 3 | Code is produced by the project's formatter and passes its linter with no unexplained suppressions (Mandatory) | Pass | `ruff format --check` and `ruff check` pass; the `noqa` are `N802` and `A002` on handler names that `http.server` fixes (the mocks) and `E501` on three import lines whose module path cannot be split, with a comment saying so. |
| 4 | Every function and method signature is type-annotated, including `-> None` (Mandatory) | Pass | `mypy --strict` passes on `src` and `tests` (228 files). |
| 5 | No bare `except:`, no swallowed exceptions; specific exceptions are raised and the cause is kept (`raise ... from`) (Mandatory) | Pass | No bare `except`; token and keyring errors are re-raised without the original text on purpose (`from None`) so no value leaks. |
| 6 | No mutable default arguments and no shadowed builtins (Mandatory) | Pass | No mutable default argument; no builtin shadowed. |
| 7 | Files, locks and connections are managed with context managers (Mandatory) | Pass | The HTTP client is used as a context manager; the temporary file in the store uses `with`. |
| 8 | Public modules, classes and functions have docstrings that say what, not how (Optional) | Pass | Public modules, classes and functions carry docstrings. |
| 9 | Logging uses `logging`, not `print`; no secrets or personal data in log output (Mandatory) | Pass | No `print` outside the CLI output module and no logging of values; tests show no credential in an operation record, the configuration file or an error text (Go criterion 6). |
| 10 | Classes and operations trace to the Design Class Diagram they implement; deviations are recorded (Mandatory) | Pass | Classes trace to DCD-001 revision 10, corrected to the built code in revision 11 (the next record); the deviations found were the resolver result, the place of the DTOs, the order of the local checks, the refusal of `/`, and the verification rule of a restore. |
| 11 | Tests exist for new behaviour, are named for the behaviour, and do not depend on order or the network (Mandatory) | Pass | 1482 tests collected for the default run and 48 integration tests deselected; the full run before the last fix gave 1475 passed and 4 skipped (the skips are POSIX-only tests on Windows), and the unit and transfer end-to-end tests gave 884 passed after it; the contract suite runs 25 fake cases in CI and 25 real-sshd cases opt-in; the live tests skip without `IACNF_SSHD_TEST`; the fakes are in process. |
| 12 | Type checker runs in strict mode without errors; `Any` is justified in a comment (Optional) | Pass | Strict mode; `Any` appears only as the `_Json` alias in the two adapters, for decoded JSON. |
| 13 | Dependencies are declared and pinned in the project's dependency file, none unused (Optional) | Fail | Dependencies are still lower bounds only (`httpx`, `keyring`); no lock file. Optional; carried from RC-045. |
| 14 | Each piece of knowledge (a business rule, constant, format, validation or query) is defined in one place; code is merged only where it expresses the same knowledge, not where it merely looks alike (Mandatory) | Pass | `OpenSshCommands` is the only place that builds an argv and holds the remote command allow-list; the confirmation refusal is shared by removal and restore in `_confirmation.py`; the host key checks are made once in `RemoteAccessResolver`; the manifest comparison is made once in `TransferRun.compared`. |
| 15 | Imports point inward: business-rule modules import no framework, database, UI or delivery-mechanism code, and there are no import cycles (Mandatory) | Pass | `lint-imports`: 4 contracts kept; the adapter imports `application` and `domain` only; the auth URL is a composition-root parameter. |
| 16 | SOLID holds: a class or module has one reason to change; new behaviour is added by extension, not by editing a type test in several places; subclasses honour the contract of their base; protocols are narrow; high-level code depends on protocols or abstract types and receives its implementations (Mandatory) | Pass | The Strategy pattern holds: use cases do not test the provider kind; the resolver builds the adapter. |
| 17 | Source is laid out in the layers and folders of the clean architecture folder structure (`domain`, `application`, `infrastructure`, `presentation` packages under `src/`, and `unit`, `integration` and `e2e` under `tests/`), in `snake_case`, and imports between the layers point inward (Mandatory) | Pass | Layers unchanged under `src/iac_node_forge`; tests in `unit`, `contract`, `integration` and `e2e`. |
| 18 | File and folder names are English, contain no space and no character outside letters, digits, `-`, `_` and `.`, and follow the casing of the language for files (Mandatory) | Pass | All names English, no spaces, snake_case. |

## Overall Verdict

Go — every Mandatory criterion passes (no shell is used locally, no secret is read, stored or placed on a command line or in the environment, and the real `~/.ssh` is guarded by a test). The one failed criterion (13, Optional) is carried from RC-045. Only a BusyBox server and Windows clients were run; a GNU userland server, password and passphrase prompts, the Windows agent service and Linux or macOS clients were not.

## Action Items

| Action | Owner | Due |
| --- | --- | --- |
| Pin or lock the Python dependencies | S01 | 2026-12-11 (MIL-007 decision date) |
| Independent confirmation by S02 of this review | S02 | 2026-12-11 (MIL-007 decision date) |

---

[MIL-007]: ../../milestones/mil-007-file-backup-and-restore.md
[QC-PY-001]: ../../../framework/qc/code/qc-programming-python.md
