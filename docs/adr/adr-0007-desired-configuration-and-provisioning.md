# Desired configuration, cost confirmation and duplicate protection

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0007 |
| CrossReference | [BC-001], [MIL-005], [ADR-0002], [ADR-0004], [ADR-0005], [ADR-0006], [UC-003], [UC-004] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-069 | [aa570c0] |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Provisioning is the first action of the product that creates something, and at Contabo it
creates a commitment. Two questions of the use cases were left open: how much of a server
description is provider-neutral and whether it is a template or one server ([UC-003]), and how a
retry is kept from creating a second server ([UC-004]). The verification note shows how the
providers differ:

- **Proxmox VE** creates a container (`POST /nodes/{node}/lxc`) or a virtual machine
  (`POST /nodes/{node}/qemu`) on a named node, needs a free identifier (`/cluster/nextid`), a
  storage and the permission `VM.Allocate`, and answers with a task (P3, P5, P6, P13). The
  identifier is chosen by the caller, so two requests with the same identifier cannot both
  succeed.
- **Contabo** creates an instance (`POST /v1/compute/instances`) from a product, an image and a
  region, and requires a contract period of 1, 12 or 24 months (C5, C6). There is no task and the
  provider chooses the instance identifier, so a lost answer followed by a retry can create and
  bill a second instance.

The existing read side offers the option kinds `node` and `storage` (Proxmox VE) and `region` and
`image` (Contabo) ([ADR-0002]). Contabo needs `product` as a third kind and Proxmox VE needs
`template` (a container template or an ISO in a storage).

Options considered for the description:

1. **One flat neutral record.** Simple to read, but it hides the period, the node and the storage,
   which are what the cost and the placement depend on.
2. **A provider-specific record per provider.** Honest, but the CLI and the store would need a type
   per provider.
3. **A neutral core with named provider-specific values.** The core is what every provider needs
   (name, provider configuration, server name, image, key names); the values are named and checked
   against the provider's declared requirements.

## Decision

A desired configuration is a named, reusable description with a neutral core and named
provider-specific values, validated against the discovered options before it is saved. Provisioning
shows the cost consequence and asks for confirmation before any request, records the intent before
the request, refuses when the name or an unfinished intent already exists, and records the server as
managed when the operation succeeds. The write surface grows by exactly the create requests.

### Rules

- **The description:** a desired configuration has a name, unique within a provider configuration,
  and is a template: each provisioning creates one server, named by `--name` or, when absent, by the
  configuration name. The neutral core is the name, the provider configuration, the image, and the
  names of the access keys to install; the key values are never stored ([ADR-0004]). Bootstrap
  hints are a bounded text.
- **Provider-specific values:** each provider declares the values it requires and how each is
  checked, as part of its capabilities.
  - Proxmox VE: `kind` (`lxc` or `qemu`), `node`, `storage` and `template` are checked against the
    discovered options; `memory_mb`, `cores` and `disk_gb` are whole numbers within stated bounds.
  - Contabo: `region`, `image` and `product` are checked against the discovered options; `period` is
    1, 12 or 24.
  A value the provider does not offer, a missing required value or an unknown name is reported
  and the configuration is not saved as valid. A configuration saved earlier is checked again at
  provisioning.
- **Cost confirmation:** before any request the CLI shows the provider, the configuration, the
  target (node and storage, or region), the image, the size, and for Contabo the product and the
  contract period with the words that the account is committed to it. The confirmation is one yes,
  and `--yes` in a non-interactive run; without it no request is sent.
- **Duplicate protection:**
  - The intent is saved before the request, with the server name, the configuration and the
    chosen values (for Proxmox VE also the identifier taken from `/cluster/nextid`).
  - Before saving it, the provider is asked for a server with that name. If one exists, or an
    unfinished intent for the same name and configuration exists, nothing is sent and the report
    says which.
  - After a timeout or a lost answer the operation is `unknown`; a retry meets the unfinished
    intent and is refused. The intent ends when the operation ends, or by `operation <id>`.
- **Managed marker:** when the operation succeeds, a `ManagedServerRecord` is saved locally, as the
  confirmation rules of [ADR-0006] expect. A Contabo tag as a provider-side marker (C20) is not
  used in this milestone.
- **Operations:** a creation is an `Operation` like a power action, with a new action value
  `provision`; the state rules of [ADR-0006] apply. For Contabo the instance is followed until
  `running`, a status of `error` or the time limit; `provisioning`, `installing` and `unknown` are
  not final.
- **Write surface:** a `ServerProvisionPort`, separate from the read port and the power port,
  with the capability `provision_server`. The only create requests are the Proxmox VE `lxc` and `qemu`
  creations and the Contabo instance creation; a test lists the write requests the mocks can
  receive and nothing else is allowed.
- **No secret:** a desired configuration, an intent, a managed-server record and an operation
  record never hold a credential, a token or a key value.
- **Not covered:** deleting, cancelling or removing a server (a later milestone), reinstalling,
  cloning, cloud-init and bootstrapping ([UC-005]).

## Consequences

**Positive:**

- The cost and the commitment are visible before anything is sent, and the period is part of the
  confirmation.
- A lost answer cannot create or bill a second server: the retry meets the intent.
- A template can be reused, and a bad value is found when it is defined, not at the provider.
- The write allow-list stays small and testable.

**Negative:**

- Two new option kinds (`product`, `template`) are added to the read side.
- The product has no delete yet: a server created in a test cannot be removed by the product, so
  the live test removes only what it created through a test-only helper.
- An unfinished intent can block the same name until it is ended by hand.
- Checking the name first is a race with another client; only the Proxmox VE identifier makes a
  second creation fail at the provider.
- The Contabo creation is exercised only against the mock; its real status sequence is unverified.

## Affected Artifacts

- [BC-001] — Objectives 1 to 3.
- [MIL-005] — task 1 delivers this ADR; Go criterion 1 requires it reviewed.
- [ADR-0002] — the capability model gains the capability `provision_server` and two option kinds.
- [ADR-0004] — the names of access keys are stored, never their values.
- [ADR-0005] — the Contabo token and request identifier apply to the create request.
- [ADR-0006] — operations, confirmation and the write allow-list are extended.
- [UC-003], [UC-004] — the use cases this decision realises.

---

[BC-001]: ../business-case.md
[MIL-005]: ../milestones/mil-005-provisioning.md
[ADR-0002]: ./adr-0002-provider-capability-model.md
[ADR-0004]: ./adr-0004-server-access-credentials.md
[ADR-0005]: ./adr-0005-contabo-credentials-and-token.md
[ADR-0006]: ./adr-0006-power-actions-and-operation-tracking.md
[UC-003]: ../use-cases/uc-003/uc.md
[UC-004]: ../use-cases/uc-004/uc.md
[UC-005]: ../use-cases/uc-005/uc.md
[aa570c0]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/aa570c0d24a2840723ff9a2db0e146999ae69381
