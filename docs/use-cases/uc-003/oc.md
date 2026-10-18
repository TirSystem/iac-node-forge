# Operation Contracts: Define desired server configuration

## Metadata
| Key | Value |
| --- | --- |
| ID | OC-004 |
| CrossReference | [SSD-006], [DM-001], [DICT-001] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Initial version<br>Accepted after RC-074 | pending |

---

## Contract: defineDesiredConfiguration

| Item | Value |
| --- | --- |
| Operation | `defineDesiredConfiguration(configuration: Text, name: Text, image: Text, accessKeyNames: List, bootstrapHint: Text, values: Map): DesiredConfigurationView` |
| Traces to | `defineDesiredConfiguration` in [SSD-006] |
| Domain Model concepts | DesiredConfiguration, ProviderValue, ProviderConfiguration, ServerOption, Capability ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- `name` is not empty and `bootstrapHint`, when given, is within the bound of 500 characters.
- The ProviderConfiguration's provider declares the Capability `provision_server`.
- `image` and every ProviderValue that the provider checks against ServerOptions
  (Proxmox VE: `node`, `storage`, `template`; Contabo: `region`, `image`, `product`) is one of
  the ServerOptions the ProviderConfiguration offers; every other value is within the bounds
  the provider declares (Proxmox VE: `kind` is `lxc` or `qemu`, `memory_mb`, `cores` and
  `disk_gb` are whole numbers within bounds; Contabo: `period` is 1, 12 or 24).
- Every value the provider requires is present and no value has a name the provider does not know.

**Postconditions**

- A DesiredConfiguration instance was created with `name`, `image`, `accessKeyNames` and
  `bootstrapHint`; if one with the same name existed for the ProviderConfiguration it was replaced.
- The DesiredConfiguration was associated with the ProviderConfiguration.
- One ProviderValue instance was created for each entry of `values` and associated with the
  DesiredConfiguration.
- The DesiredConfiguration was persisted without any secret attribute; only the names of
  access keys were stored.
- No request was sent to the provider other than the reads of its capabilities and options.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| The ProviderConfiguration does not exist or its access is not valid | Reported; nothing is saved. |
| The provider does not declare the Capability | Reported as unsupported; nothing is saved. |
| `name` is empty or the bootstrap hint is over the bound | Reported as invalid; nothing is saved. |
| The image or a value is not offered, is out of bounds, is required and missing, or is unknown | Every such choice is reported with its name and, where the provider offers choices, the choices; no DesiredConfiguration is created or replaced, so nothing is saved as valid. |
| The provider cannot be reached when its options are read | Reported as a provider failure; nothing is saved. |

## Contract: validateDesiredConfiguration

| Item | Value |
| --- | --- |
| Operation | `validateDesiredConfiguration(configuration: Text, name: Text): DesiredConfigurationView` |
| Traces to | `validateDesiredConfiguration` in [SSD-006] |
| Domain Model concepts | DesiredConfiguration, ProviderValue, ProviderConfiguration, ServerOption ([DM-001]) |

**Preconditions**

- A ProviderConfiguration identified by `configuration` exists and its provider access is valid.
- A DesiredConfiguration with `name` exists for it.

**Postconditions**

- No instance was created, associated or modified.
- The result states whether the image and every ProviderValue of the DesiredConfiguration is still
  offered or within bounds, and each choice that is not.

**Exceptions**

| Condition (failing precondition) | Outcome |
| --- | --- |
| No DesiredConfiguration with `name` exists | Reported as not found. |
| The ProviderConfiguration does not exist or its access is not valid | Reported; nothing is changed. |
| The provider cannot be reached when its options are read | Reported as a provider failure; nothing is changed. |

---

[SSD-006]: ./ssd.md
[DM-001]: ../../domain-model.md
[DICT-001]: ../../dictionary.md
