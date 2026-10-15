# Contabo credentials and token handling

## Metadata
| Key | Value |
| --- | --- |
| ID | ADR-0005 |
| CrossReference | [BC-001], [MIL-003], [ADR-0002], [ADR-0003], [ADR-0004], [UC-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-049 | pending |

Allowed Status values: `Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`.

---

## Context

Proxmox VE is reached with one API token string. Contabo is different, as verified in the
provider verification note (C1 to C3, C19):

- Access needs **four values** from the customer control panel: client ID, client secret,
  API user and API password.
- They are exchanged at a separate authentication service (OAuth2 password grant) for a
  **bearer token**, which every call then sends. The token's lifetime is not stated.
- Every instance call needs an `x-request-id` header; the service answers 429 when a rate
  limit is reached.

The domain value object `Credentials` holds one `secret`, and the credential store and the
prompt are written for one value. [ADR-0003] requires that no secret is stored in the
configuration, and a Contabo configuration must be able to use the same ports as a Proxmox
VE one ([ADR-0002]).

Options considered:

1. **Pack the four values into one string** (for example JSON) and keep `Credentials` as it
   is. Simple, but the string is opaque, easy to mis-split and hard to validate or prompt
   for.
2. **A second credentials class for Contabo.** Clear types, but every port that accepts
   `Credentials` (provider, store, prompt) would need a union or a second overload, and the
   interface would no longer be provider-neutral.
3. **One `Credentials` holding named secret values.** Proxmox VE uses one value named
   `token`; Contabo uses four. The ports are unchanged.

## Decision

`Credentials` holds named secret values, hidden from every `repr` and refusing to be
persisted, and a provider declares which names it needs; Proxmox VE uses `token` and Contabo
uses `client_id`, `client_secret`, `api_user` and `api_password`. The Contabo adapter
exchanges them for a bearer token on first use, keeps the token only in memory, and obtains a
new one once after a 401, and the platform credential store keeps the named values of one
credential reference as a single entry.

### Details

- **Prompt:** the console prompt asks for each name the provider declares, without echo.
- **Configuration:** unchanged. It holds the credential reference name only ([ADR-0003]);
  the Contabo address in the configuration is the API address, and the authentication
  address is a constant of the adapter that a test may override.
- **Token:** never written to a file, a log or an error text. A token that expires is
  replaced once; a second failure is an authentication error.
- **Requests:** every call carries a fresh `x-request-id`; 429 and 5xx become provider
  errors that name the provider and the status, never the headers.
- **Single-value case:** the existing Proxmox VE code keeps one `token`; a helper returns
  the single value and refuses when there are several.
- **Not decided here:** Windows Hello gating, and the lifetime of the token, which the
  provider documentation does not state.

## Consequences

**Positive:**

- The provider, store and prompt ports stay provider-neutral ([ADR-0002]).
- Each Contabo value can be validated and prompted for by name.
- No secret enters the configuration file; the token lives in memory only.

**Negative:**

- The domain value object and its tests change, and the Proxmox VE call sites use a helper
  instead of the plain attribute.
- The keyring entry for Contabo holds four values in one serialised string, so a partial
  update is not possible: the entry is replaced whole.
- The 401 retry means one extra request after a long idle time, and a wrong lifetime
  assumption would only show in a live run.

## Affected Artifacts

- [BC-001] — Objective 4 (no secrets in configuration).
- [MIL-003] — task 1 delivers this ADR; Go criterion 1 requires it reviewed.
- [ADR-0002] — the interface stays provider-neutral.
- [ADR-0003] — extends it to several values and a token.
- [ADR-0004] — unrelated access path (servers over SSH); named for completeness.
- [UC-001] — the credentials of a provider are what the use case validates.

---

[BC-001]: ../business-case.md
[MIL-003]: ../milestones/mil-003-contabo-read-only-adapter.md
[ADR-0002]: ./adr-0002-provider-capability-model.md
[ADR-0003]: ./adr-0003-credential-storage.md
[ADR-0004]: ./adr-0004-server-access-credentials.md
[UC-001]: ../use-cases/uc-001/uc.md
