# Design Class Diagram

## Metadata
| Key | Value |
| --- | --- |
| ID | DCD-001 |
| CrossReference | [DM-001], [OC-001], [SSD-001], [SSD-002], [SSD-003], [DICT-001], [ADR-0002] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-15 | Deprecated | Jens Tirsvad Nielsen | AI (named by S01) | Multiplicities and navigability on every association; Credentials, ProviderKind and persisted attributes added; every method traced (RC review)<br>Accepted after RC-038 | [de601dd] |
| 2026-10-15 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Revised after the implementation: ProviderResolver, result types, CredentialSource, Timestamp<br>Accepted after RC-040 | pending |

---

## Purpose and Scope

The design classes that realise the system operations of [SSD-001], [SSD-002] and
[SSD-003] and the contract of [OC-001], arranged in the layers of the clean
architecture: `domain`, `application`, `infrastructure` and `presentation`. Names are the
IT terms of [DICT-001], in the language-neutral spelling; each language applies its own
naming convention. Dependencies point inward: `application` depends on `domain`;
`infrastructure` and `presentation` depend on `application` and `domain`.

Revised on 2026-10-15 after the implementation of MIL-002: the provider resolver, the
result types, the credential source and the timestamp type were added; `getServer` and
`listServers` accept a configuration identifier or display name.

## Diagram

```plantuml
@startuml
hide empty members
package domain {
  enum ProviderKind {
    PROXMOX_VE
    CONTABO
  }
  class ProviderConfiguration {
    - configurationId : ConfigurationId
    - providerKind : ProviderKind
    - displayName : Text
    - address : Url
    - credentialReference : CredentialReference
  }
  class CredentialReference {
    - name : Text
    - storeKind : Text
  }
  class Credentials {
    - secret : Text
  }
  class AccessResult {
    - succeeded : Boolean
    - reason : Text
  }
  class Capability {
    - name : Text
  }
  class ServerOption {
    - kind : Text
    - value : Text
  }
  class Server {
    - serverIdentifier : Text
    - name : Text
    - state : Text
    - size : Text
    - addresses : List
    - managed : Boolean
  }
  class ManagedServerRecord {
    - configurationId : ConfigurationId
    - serverIdentifier : Text
    - recordedAt : Timestamp
  }
}
package application {
  interface ProviderPort {
    + validateAccess(address, credentials) : AccessResult
    + discoverCapabilities(configuration) : List
    + listServerOptions(configuration, optionKind) : List
    + listServers(configuration) : List
    + getServer(configuration, serverIdentifier) : Server
  }
  interface ConfigurationStore {
    + save(configuration) : void
    + loadAll() : List
    + managedServers(configurationId) : List
  }
  interface CredentialStore {
    + put(reference, credentials) : void
    + get(reference) : Credentials
  }
  interface CredentialPrompt {
    + ask(providerKind) : Credentials
  }
  interface ProviderResolver {
    + providerFor(configuration) : ProviderPort
  }
  class AccessCheck
  class SavedConfiguration
  class CapabilityReport
  class ServerSummary
  class ServerListing
  class ProviderFailure
  class ConfigureProviderAccess {
    + validateAccess(providerKind, address, credentials) : AccessCheck
    + saveProviderConfiguration(providerKind, address, displayName, cacheCredential) : SavedConfiguration
  }
  class DiscoverCapabilities {
    + discoverCapabilities(configuration) : CapabilityReport
    + listServerOptions(configuration, optionKind) : List
  }
  class ListServers {
    + listServers(configuration) : ServerListing
    + inspectServer(configuration, serverIdentifier) : ServerSummary
  }
}
package infrastructure {
  class ProxmoxProvider
  class JsonLinesConfigurationStore
  class PlatformCredentialStore
  class ConsoleCredentialPrompt
}
package presentation {
  class CliApplication
  class CliProviderResolver
  class CredentialSource
}

ProviderConfiguration "0..*" --> "1" ProviderKind
ProviderConfiguration "0..*" --> "0..1" CredentialReference
ManagedServerRecord "0..*" --> "1" ProviderConfiguration
ConfigureProviderAccess ..> ProviderPort
ConfigureProviderAccess ..> ConfigurationStore
ConfigureProviderAccess ..> CredentialStore
DiscoverCapabilities ..> ProviderResolver
DiscoverCapabilities ..> ConfigurationStore
ListServers ..> ProviderResolver
ProviderResolver ..> ProviderPort
ListServers ..> ConfigurationStore
ProxmoxProvider ..|> ProviderPort
JsonLinesConfigurationStore ..|> ConfigurationStore
PlatformCredentialStore ..|> CredentialStore
ConsoleCredentialPrompt ..|> CredentialPrompt
CliApplication ..> ConfigureProviderAccess
CliApplication ..> DiscoverCapabilities
CliApplication ..> ListServers
CliApplication ..> CredentialPrompt
CliProviderResolver ..|> ProviderResolver
CliApplication ..> CredentialSource
CredentialSource ..> CredentialStore
CredentialSource ..> CredentialPrompt
@enduml
```

## Class Table

| Class | Refines (Domain Model concept) | Responsibility | Attributes | Operations |
| --- | --- | --- | --- | --- |
| ProviderKind | Provider | Names the provider a configuration connects to. | PROXMOX_VE, CONTABO | none |
| ProviderConfiguration | Provider configuration | Holds the saved settings for one provider connection. | configurationId, providerKind, displayName, address, credentialReference | none |
| CredentialReference | Credential reference | Names a secret kept by the platform. | name, storeKind | none |
| Credentials | Credential reference | Carries a secret for the duration of one call; never persisted. | secret | none |
| AccessResult | Access check | Carries the outcome of an access check. | succeeded, reason | none |
| Capability | Capability | Names one supported action or option. | name | none |
| ServerOption | Server option | One choice offered by a provider. | kind, value | none |
| Server | Server | Describes a server and whether this client manages it. | serverIdentifier, name, state, size, addresses, managed | none |
| ManagedServerRecord | Managed server | Records that this client manages a server. | configurationId, serverIdentifier, recordedAt | none |
| ProviderPort | (provider) | The boundary to a provider's interface; one adapter per provider. | none | validateAccess, discoverCapabilities, listServerOptions, listServers, getServer |
| ConfigurationStore | (configuration) | The boundary to the client's saved configuration. | none | save, loadAll, managedServers |
| CredentialStore | Credential reference | The boundary to the platform credential store. | none | put, get |
| CredentialPrompt | (credentials) | The boundary to asking the user for a secret. | none | ask |
| ProviderResolver | (provider) | Gives the provider port for one saved configuration, built with that configuration's credentials. | none | providerFor |
| AccessCheck, SavedConfiguration, CapabilityReport, ServerSummary, ServerListing, ProviderFailure | (result types) | Data transfer objects that cross from the use cases to presentation so no domain entity does. | outcome, reason, entries, failures | none |
| ConfigureProviderAccess | Provider configuration | Realises UC-001: validates access and saves a configuration; keeps the validated credentials in memory until the save or the next check, and never persists them. | none | validateAccess, saveProviderConfiguration |
| DiscoverCapabilities | Capability | Realises UC-002: discovers capabilities and options. | none | discoverCapabilities, listServerOptions |
| ListServers | Server | Realises UC-007: lists and inspects servers. | none | listServers, inspectServer |
| ProxmoxProvider | (provider) | Adapter for the Proxmox VE interface (read-only in this slice). | none | implements ProviderPort |
| JsonLinesConfigurationStore | (configuration) | Adapter that keeps configuration as JSON Lines without secrets. | none | implements ConfigurationStore |
| PlatformCredentialStore | Credential reference | Adapter for the operating system credential store. | none | implements CredentialStore |
| ConsoleCredentialPrompt | (credentials) | Adapter that asks for a secret on the console. | none | implements CredentialPrompt |
| CliProviderResolver | (provider) | Builds the provider adapter for a configuration after obtaining its credentials. | none | implements ProviderResolver |
| CredentialSource | Credential reference | Obtains a secret: the credential store first, then the prompt (ADR-0003). | none | obtain |
| CliApplication | (client) | Entry point and composition root of the command-line client. | none | one command per use case operation |

## Method Traceability

| Method signature | Operation Contract / SSD message |
| --- | --- |
| ConfigureProviderAccess.validateAccess(providerKind, address, credentials) : AccessResult | `validateAccess` in [SSD-001] |
| ConfigureProviderAccess.saveProviderConfiguration(providerKind, address, displayName, cacheCredential) : ConfigurationId | `saveProviderConfiguration` in [OC-001] and [SSD-001] |
| DiscoverCapabilities.discoverCapabilities(configuration) : CapabilityReport | `discoverCapabilities` in [SSD-002]; `configuration` is an identifier or a display name |
| DiscoverCapabilities.listServerOptions(configuration, optionKind) : List | `listServerOptions` in [SSD-002] |
| ListServers.listServers(configuration) : ServerListing | `listServers` in [SSD-003]; the configuration argument is optional and filters |
| ListServers.inspectServer(configuration, serverIdentifier) : ServerSummary | `inspectServer` in [SSD-003] |
| ProviderResolver.providerFor(configuration) | Supporting operation of `discoverCapabilities`, `listServerOptions`, `listServers` and `inspectServer` (credentials differ per configuration) |
| ProviderPort.validateAccess(address, credentials) | `validateAccess` in [SSD-001] |
| ProviderPort.discoverCapabilities(configuration) | `discoverCapabilities` in [SSD-002] |
| ProviderPort.listServerOptions(configuration, optionKind) | `listServerOptions` in [SSD-002] |
| ProviderPort.listServers(configuration) | `listServers` in [SSD-003] |
| ProviderPort.getServer(configuration, serverIdentifier) | `inspectServer` in [SSD-003] |
| ConfigurationStore.save(configuration) | `saveProviderConfiguration` in [OC-001] |
| ConfigurationStore.loadAll(), managedServers(configurationId) | `listServers` in [SSD-003] (managed marking) and the configuration lookup of every message |
| CredentialStore.put(reference, credentials) | `saveProviderConfiguration` in [OC-001] (cacheCredential) |
| CredentialStore.get(reference) | `validateAccess` in [SSD-001] and `discoverCapabilities` in [SSD-002] (stored credentials) |
| CredentialPrompt.ask(providerKind) | `validateAccess` in [SSD-001] (credentials parameter) |

## Pattern Annotations

| Pattern | Classes | Rationale |
| --- | --- | --- |
| Ports and adapters | ProviderPort, ConfigurationStore, CredentialStore, CredentialPrompt and their adapters | Keeps the application free of provider, file and platform detail; a second provider is a new adapter ([ADR-0002]). |
| Composition root | CliApplication | The only place that names infrastructure classes. |
| Resolver | ProviderResolver, CliProviderResolver | The adapter takes its credentials at construction, and one run spans several configurations, so a port instance per configuration is resolved on demand. |
| Capability set | Capability, ProviderPort.discoverCapabilities | Provider differences are declared, not hidden ([ADR-0002]). |

## Dependency Check

No circular dependencies. `domain` depends on nothing; `application` depends on `domain`;
`infrastructure` implements `application` ports; `presentation` is the composition root
and may name every layer.

---

[DM-001]: ./domain-model.md
[OC-001]: ./use-cases/uc-001/oc.md
[SSD-001]: ./use-cases/uc-001/ssd.md
[SSD-002]: ./use-cases/uc-002/ssd.md
[SSD-003]: ./use-cases/uc-007/ssd.md
[DICT-001]: ./dictionary.md
[ADR-0002]: ./adr/adr-0002-provider-capability-model.md
[de601dd]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/de601dd67be72a7d032de2146b4ec9cc8a213aec
