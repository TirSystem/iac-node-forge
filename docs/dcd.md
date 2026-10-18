# Design Class Diagram

## Metadata
| Key | Value |
| --- | --- |
| ID | DCD-001 |
| CrossReference | [DM-001], [OC-001], [OC-002], [OC-003], [SSD-001], [SSD-002], [SSD-003], [SSD-004], [SSD-005], [DICT-001], [ADR-0002], [ADR-0005], [ADR-0006], [ADR-0007], [SSD-006], [SSD-007], [OC-004], [OC-005], [ADR-0008], [SSD-008], [OC-006] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-18 | Deprecated | Jens Tirsvad Nielsen | AI as stand-in for S02 | Revision 7: aligned with the built provisioning code (MIL-005 task 12)<br>Accepted after RC-079 | [9a23c07] |
| 2026-10-18 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Revision 8: ServerRemovalPort, RemoveServer, RemovalKind, RemovalBlock, RemovalPreview, RemovalResult, RemovalOutcome; Operation.consequence; ManagedServerRecord can be ended (MIL-006)<br>Accepted after RC-088 | pending |

---

## Purpose and Scope

The design classes that realise the system operations of [SSD-001], [SSD-002] and
[SSD-003] and the contract of [OC-001], arranged in the layers of the clean
architecture: `domain`, `application`, `infrastructure` and `presentation`. Names are the
IT terms of [DICT-001], in the language-neutral spelling; each language applies its own
naming convention. Dependencies point inward: `application` depends on `domain`;
`infrastructure` and `presentation` depend on `application` and `domain`.

Revised for MIL-006 on 2026-10-18 (revision 8): the write side grows by the removal of a server
([ADR-0008]). `ServerRemovalPort` is a fourth narrow port beside `ProviderPort`, `ServerPowerPort`
and `ServerProvisionPort`; it states its `RemovalKind` (`DESTROY` at Proxmox VE, `CANCEL` at
Contabo), says through `RemovalBlock` whether a server can be removed now (running, already
removed), gives the consequence text and sends the one removal request. The use case `RemoveServer`
realises [UC-012] with `previewRemoval`, `requestRemoval` and `completeRemoval`. The action of an
`Operation` gains `REMOVE` (the type keeps the name `PowerAction`; `ControlServerPower` refuses
`REMOVE` as it refuses `PROVISION`), and an `Operation` gains the optional, bounded `consequence`,
the text that was shown before the confirmation. A removal needs no intent store: a retry meets the
new state. A `ManagedServerRecord` is ended, not deleted, through a new
`ConfigurationStore.endManagedServer`, for the same reason `saveManagedServer` is on that port: the
file of managed servers is read through it. The record gains `endedAt` and `endedByOperationId`, and
`managedServers` returns only the records that are not ended. `ProviderResolver` gains `removalFor`;
the capability `remove_server` is a value, not a class. `Confirmation` also carries the identifier
typed and, for an unmanaged server, the identifier typed again.

Revised after the code of MIL-005 on 2026-10-18 (revision 7): the file is kept by four adapters, one per
port (`JsonLinesConfigurationStore`, `JsonLinesOperationStore`, `JsonLinesDesiredConfigurationStore`,
`JsonLinesProvisionIntentStore`) over one file, because one class cannot implement `save` and
`loadAll` of four ports; `ProvisionPreview` also carries `outcome`, `reason` and `providerName`;
`listDesiredConfigurations` takes `check` (by default it does not call the provider); a failed completion
uses `REJECTED`; the image of a desired configuration is the single source of the image (the rule named
`template` or `image` checks it, and no second value of that name is allowed); a timeout of the create
request, or a 5xx at Contabo, ends the operation as `UNKNOWN` and leaves the intent pending
([ADR-0007]).

Revised for MIL-005 on 2026-10-18 (revision 6): the write side grows by the creation of a server
([ADR-0007]). `ServerProvisionPort` is a third narrow port beside `ProviderPort` and
`ServerPowerPort`; `DesiredConfigurationStore` and `ProvisionIntentStore` keep the desired
configurations and the intents; the use cases `DefineDesiredConfiguration` and `ProvisionServer`
realise [UC-003] and [UC-004]. The intent has its own store and is not added to `OperationStore`
because it exists before the operation (it is saved before the request), has its own key and its
own end, and an operation can be lost while the intent must survive; the two are linked by
`operationId`. A managed server is saved through a new `ConfigurationStore.saveManagedServer`,
because the file of managed servers is already read through that port and a second port for one
record type would split one file. `ProviderResolver` gains `provisionFor`; the option kinds
`product` and `template` and the capability `provision_server` are values, not classes. The
action of an `Operation` gains `PROVISION` (the type keeps the name `PowerAction`) and its
`serverIdentifier` becomes optional, because a provision operation can exist before the server
is known.

Revised for MIL-004 on 2026-10-15: `ServerPowerPort` and `OperationStore`, the `Operation` record and
the use cases `ControlServerPower` and `TrackOperation` ([ADR-0006]).

Revised again after the code of MIL-004 on 2026-10-16 (revision 5): `operationState` returns the
`Operation`; `finishedAt`, `providerReference` and `detail` are optional; `previewPowerAction`,
the result types `Confirmation`, `OperationSummary` and `PowerActionResult`, and the `pollInterval`
option were added; `TrackOperation` also depends on `ConfigurationStore`.

Revised again on 2026-10-15 for MIL-003: `Credentials` holds named values, `ProviderKind`
declares the credential names it needs and `ContaboProvider` is a second adapter
([ADR-0005]).

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
    - values : Map
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
  enum PowerAction {
    START
    SHUTDOWN
    STOP
    RESTART
    PROVISION
    REMOVE
  }
  enum RemovalKind {
    DESTROY
    CANCEL
  }
  enum OperationState {
    RUNNING
    SUCCEEDED
    FAILED
    UNKNOWN
  }
  class Operation {
    - operationId : OperationId
    - configurationId : ConfigurationId
    - serverIdentifier : Text [0..1]
    - action : PowerAction
    - state : OperationState
    - startedAt : Timestamp
    - finishedAt : Timestamp [0..1]
    - providerReference : Text [0..1]
    - detail : Text [0..1]
    - consequence : Text [0..1]
  }
  class ManagedServerRecord {
    - configurationId : ConfigurationId
    - serverIdentifier : Text
    - recordedAt : Timestamp
    - endedAt : Timestamp [0..1]
    - endedByOperationId : OperationId [0..1]
  }
  class ProviderValue {
    - name : Text
    - value : Text
  }
  class DesiredConfiguration {
    - configurationId : ConfigurationId
    - desiredName : Text
    - image : Text
    - accessKeyNames : List
    - bootstrapHint : Text [0..1]
    - values : List
  }
  enum IntentState {
    PENDING
    ENDED
  }
  class ProvisionIntent {
    - intentId : IntentId
    - configurationId : ConfigurationId
    - desiredName : Text
    - serverName : Text
    - image : Text
    - values : List
    - reservedIdentifier : Text [0..1]
    - state : IntentState
    - recordedAt : Timestamp
    - operationId : OperationId [0..1]
  }
  class ValueRule {
    - name : Text
    - required : Boolean
    - optionKind : Text [0..1]
    - allowed : List
    - minimum : Integer [0..1]
    - maximum : Integer [0..1]
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
  interface ServerPowerPort {
    + requestPower(configuration, serverIdentifier, action) : Operation
    + operationState(configuration, operation) : Operation
  }
  interface ServerProvisionPort {
    + valueRules(configuration) : List
    + reserveIdentifier(configuration) : Text [0..1]
    + costConsequence(configuration, desiredConfiguration) : Text [0..1]
    + requestProvision(configuration, desiredConfiguration, serverName, reservedIdentifier) : Operation
    + operationState(configuration, operation) : Operation
  }
  enum RemovalBlock {
    RUNNING
    ALREADY_REMOVED
  }
  interface ServerRemovalPort {
    + removalKind(configuration) : RemovalKind
    + removalBlock(configuration, server) : RemovalBlock [0..1]
    + consequence(configuration, server) : Text
    + requestRemoval(configuration, server) : Operation
    + operationState(configuration, operation) : Operation
  }
  interface OperationStore {
    + save(operation) : void
    + load(operationId) : Operation
  }
  interface DesiredConfigurationStore {
    + save(desiredConfiguration) : void
    + load(configurationId, desiredName) : DesiredConfiguration [0..1]
    + loadAll(configurationId) : List
  }
  interface ProvisionIntentStore {
    + save(intent) : void
    + load(intentId) : ProvisionIntent
    + findPending(configurationId, serverName) : ProvisionIntent [0..1]
    + loadByOperation(operationId) : ProvisionIntent [0..1]
  }
  interface ConfigurationStore {
    + save(configuration) : void
    + loadAll() : List
    + managedServers(configurationId) : List
    + saveManagedServer(record) : void
    + endManagedServer(configurationId, serverIdentifier, endedAt, operationId) : void
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
    + powerFor(configuration) : ServerPowerPort
    + provisionFor(configuration) : ServerProvisionPort
    + removalFor(configuration) : ServerRemovalPort
  }
  class ControlServerPower {
    + previewPowerAction(configuration, serverIdentifier, action) : PowerActionResult
    + requestPowerAction(configuration, serverIdentifier, action, confirmation) : PowerActionResult
  }
  class TrackOperation {
    + followOperation(operationId, timeLimit, pollInterval) : OperationSummary
    + showOperation(operationId) : OperationSummary
  }
  class DesiredConfigurationValidator {
    + check(configuration, desiredConfiguration) : List
  }
  class DefineDesiredConfiguration {
    + defineDesiredConfiguration(configuration, name, image, accessKeyNames, bootstrapHint, values) : DesiredConfigurationView
    + validateDesiredConfiguration(configuration, name) : DesiredConfigurationView
    + listDesiredConfigurations(configuration, check) : List
  }
  class ProvisionServer {
    + previewProvisioning(configuration, desiredName, serverName) : ProvisionPreview
    + requestProvisioning(configuration, desiredName, serverName, confirmation) : ProvisionResult
    + completeProvisioning(operationId) : ProvisionResult
  }
  enum ProvisionOutcome {
    READY
    REQUESTED
    COMPLETED
    INCOMPLETE
    REJECTED
    UNSUPPORTED
    INVALID
    NAME_EXISTS
    INTENT_PENDING
    NOT_CONFIRMED
  }
  class RemoveServer {
    + previewRemoval(configuration, serverIdentifier) : RemovalPreview
    + requestRemoval(configuration, serverIdentifier, confirmation) : RemovalResult
    + completeRemoval(operationId) : RemovalResult
  }
  enum RemovalOutcome {
    READY
    REQUESTED
    COMPLETED
    INCOMPLETE
    REJECTED
    UNSUPPORTED
    NOT_FOUND
    RUNNING_REFUSED
    ALREADY_REMOVED
    NOT_CONFIRMED
    IDENTIFIER_MISMATCH
  }
  class DesiredConfigurationView
  class ProvisionPreview
  class ProvisionResult
  class RemovalPreview
  class RemovalResult
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
  class ContaboProvider
  class JsonLinesConfigurationStore
  class JsonLinesOperationStore
  class JsonLinesDesiredConfigurationStore
  class JsonLinesProvisionIntentStore
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
ContaboProvider ..|> ProviderPort
ProxmoxProvider ..|> ServerPowerPort
ContaboProvider ..|> ServerPowerPort
ProxmoxProvider ..|> ServerProvisionPort
ContaboProvider ..|> ServerProvisionPort
ProxmoxProvider ..|> ServerRemovalPort
ContaboProvider ..|> ServerRemovalPort
ControlServerPower ..> ProviderResolver
ServerProvisionPort ..> ValueRule
ControlServerPower ..> OperationStore
ControlServerPower ..> ConfigurationStore
TrackOperation ..> ProviderResolver
TrackOperation ..> OperationStore
TrackOperation ..> ConfigurationStore
ServerRemovalPort ..> RemovalKind
ServerRemovalPort ..> RemovalBlock
RemoveServer ..> ProviderResolver
RemoveServer ..> OperationStore
RemoveServer ..> ConfigurationStore
ManagedServerRecord "0..1" --> "0..1" Operation
Operation "0..*" --> "1" PowerAction
Operation "0..*" --> "1" OperationState
DesiredConfiguration "0..*" --> "1" ProviderConfiguration
DesiredConfiguration "1" *-- "0..*" ProviderValue
ProvisionIntent "1" *-- "0..*" ProviderValue
ProvisionIntent "0..*" --> "1" DesiredConfiguration
ProvisionIntent "0..*" --> "1" IntentState
ProvisionIntent "0..1" --> "0..1" Operation
DesiredConfigurationValidator ..> ProviderResolver
DefineDesiredConfiguration ..> DesiredConfigurationValidator
DefineDesiredConfiguration ..> DesiredConfigurationStore
DefineDesiredConfiguration ..> ConfigurationStore
ProvisionServer ..> DesiredConfigurationValidator
ProvisionServer ..> ProviderResolver
ProvisionServer ..> DesiredConfigurationStore
ProvisionServer ..> ProvisionIntentStore
ProvisionServer ..> OperationStore
ProvisionServer ..> ConfigurationStore
JsonLinesConfigurationStore ..|> ConfigurationStore
JsonLinesOperationStore ..|> OperationStore
JsonLinesDesiredConfigurationStore ..|> DesiredConfigurationStore
JsonLinesProvisionIntentStore ..|> ProvisionIntentStore
PlatformCredentialStore ..|> CredentialStore
ConsoleCredentialPrompt ..|> CredentialPrompt
CliApplication ..> ConfigureProviderAccess
CliApplication ..> DiscoverCapabilities
CliApplication ..> ListServers
CliApplication ..> DefineDesiredConfiguration
CliApplication ..> ProvisionServer
CliApplication ..> RemoveServer
CliApplication ..> ControlServerPower
CliApplication ..> TrackOperation
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
| ProviderKind | Provider | Names the provider a configuration connects to and the credential names it needs (`token` for Proxmox VE; `client_id`, `client_secret`, `api_user`, `api_password` for Contabo). | PROXMOX_VE, CONTABO, credentialNames | none |
| ProviderConfiguration | Provider configuration | Holds the saved settings for one provider connection. | configurationId, providerKind, displayName, address, credentialReference | none |
| CredentialReference | Credential reference | Names a secret kept by the platform. | name, storeKind | none |
| Credentials | Credential reference | Carries the named secret values of one provider for the duration of a run; hidden in every representation and never persisted ([ADR-0005]). | values | none |
| AccessResult | Access check | Carries the outcome of an access check. | succeeded, reason | none |
| Capability | Capability | Names one supported action or option, for example `list_servers`, the four power actions, `provision_server` and `remove_server`. | name | none |
| ServerOption | Server option | One choice offered by a provider. The kinds are `node`, `storage` and `template` (Proxmox VE), `region`, `image` and `product` (Contabo) ([ADR-0002], [ADR-0007]). | kind, value | none |
| Server | Server | Describes a server and whether this client manages it. | serverIdentifier, name, state, size, addresses, managed | none |
| ManagedServerRecord | Managed server | Records that this client manages a server. A removal ends it: `endedAt` and `endedByOperationId` are set and the record is kept; it no longer counts as managed, and a server of the same identifier created later is a new record. | configurationId, serverIdentifier, recordedAt, endedAt, endedByOperationId | none |
| ProviderValue | Provider-specific value | One named value of a desired configuration or of an intent (a node, a storage, a region, a product, a period, a size); an immutable name and value pair. | name, value | none |
| DesiredConfiguration | Desired configuration | A named, reusable description of the server wanted, unique by (configurationId, desiredName); holds the neutral core and its ProviderValues, only the names of access keys, never a key value; `bootstrapHint` is bounded to 500 characters. | configurationId, desiredName, image, accessKeyNames, bootstrapHint, values | none |
| IntentState | Provision intent | The two states of an intent: it is pending until its operation ends. | PENDING, ENDED | none |
| ProvisionIntent | Provision intent | The record saved before the create request: server name, a copy of the chosen values and, for Proxmox VE, the reserved identifier; linked to its operation by `operationId` once the request is made. Never holds a secret. | intentId, configurationId, desiredName, serverName, image, values, reservedIdentifier, state, recordedAt, operationId | none |
| ValueRule | Provider-specific value | What a provider declares about one ProviderValue: its name, whether it is required, the option kind it is checked against, or the allowed values or bounds. | name, required, optionKind, allowed, minimum, maximum | none |
| ProviderPort | (provider) | The boundary to a provider's interface; one adapter per provider. | none | validateAccess, discoverCapabilities, listServerOptions, listServers, getServer |
| ConfigurationStore | (configuration) | The boundary to the client's saved configuration, including the managed servers; `managedServers` returns the records that are not ended, and `endManagedServer` ends one without deleting it. | none | save, loadAll, managedServers, saveManagedServer, endManagedServer |
| CredentialStore | Credential reference | The boundary to the platform credential store. | none | put, get |
| CredentialPrompt | (credentials) | The boundary to asking the user for a secret. | none | ask |
| ProviderResolver | (provider) | Gives the provider port, the power port, the provision port and the removal port for one saved configuration, built with that configuration's credentials. | none | providerFor, powerFor, provisionFor, removalFor |
| AccessCheck, SavedConfiguration, CapabilityReport, ServerSummary, ServerListing, ProviderFailure, OperationSummary, PowerActionResult | (result types) | Data transfer objects that cross from the use cases to presentation so no domain entity does. | outcome, reason, entries, failures | none |
| Confirmation | Consequence | What the user gave before a request is sent: `confirmed`, and for a removal the identifier typed (`typedIdentifier`) and, for a server not managed by this client, the identifier typed again (`unmanagedIdentifier`). | confirmed, typedIdentifier, unmanagedIdentifier | none |
| DesiredConfigurationView | Desired configuration | Result of defining, validating or listing a desired configuration: its name, configuration, image, access key names, bootstrap hint, values, whether it is valid and each problem. | configurationId, name, image, accessKeyNames, bootstrapHint, values, valid, problems | none |
| ProvisionPreview | Provision intent | What will be created, or why nothing can be: the outcome and reason, provider, configuration, desired name, server name, target, image, size, values and the cost consequence text (empty when the provider imposes none). | outcome, reason, providerName, providerKind, configurationId, desiredName, serverName, target, image, size, values, costConsequence | none |
| ProvisionResult | Operation | Result of requesting or completing a provisioning: the outcome, the reason, the operation summary when one exists, the server identifier when known, and the state left at the provider. | outcome, reason, operation, serverIdentifier, stateLeft | none |
| ProvisionOutcome | Operation | The outcomes of a preview, a request and a completion: READY (preview offered), REQUESTED, COMPLETED (server recorded as managed), INCOMPLETE (operation unfinished, unknown or without a server identifier), REJECTED (provider refused, or the operation ended as failed), UNSUPPORTED, INVALID, NAME_EXISTS, INTENT_PENDING, NOT_CONFIRMED. | READY, REQUESTED, COMPLETED, INCOMPLETE, REJECTED, UNSUPPORTED, INVALID, NAME_EXISTS, INTENT_PENDING, NOT_CONFIRMED | none |
| PowerAction, OperationState | Operation | The four power actions plus PROVISION and REMOVE, the kind of an operation (the type keeps its name; `requestPowerAction` refuses PROVISION and REMOVE), and the four states of an operation. | START, SHUTDOWN, STOP, RESTART, PROVISION, REMOVE; RUNNING, SUCCEEDED, FAILED, UNKNOWN | none |
| Operation | Operation | One requested action and its recorded outcome; never holds a secret. `serverIdentifier`, `finishedAt`, `providerReference` and `detail` are empty until set (`serverIdentifier` for a provision operation until the provider names the server); `detail` is bounded to 500 characters. For a removal, `consequence` (bounded to 500 characters, empty for every other action) is the text shown before the confirmation, kept as shown; `detail` holds the outcome and, for a cancellation, the effective date the provider reports. | operationId, configurationId, serverIdentifier, action, state, startedAt, finishedAt, providerReference, detail, consequence | none |
| ServerPowerPort | (provider) | The boundary for the four power requests and for reading an operation's state; a narrow port beside ProviderPort ([ADR-0006]). | none | requestPower, operationState (one read; returns the operation updated, polling belongs to the caller) |
| OperationStore | (configuration) | The boundary to the record of operations. | none | save, load |
| ServerProvisionPort | (provider) | The boundary for the creation of a server: the provider's ValueRules, the reserved identifier (Proxmox VE `nextid`; empty for Contabo), the cost consequence text, the one create request, and the state of a provision operation; a narrow third port beside ProviderPort and ServerPowerPort ([ADR-0007]). | none | valueRules, reserveIdentifier, costConsequence, requestProvision, operationState |
| RemovalKind | Removal kind | The two ways a provider ends a server: DESTROY (now, disks released; Proxmox VE) and CANCEL (a request with an effective date reported by the provider, the contract running on until then; Contabo). | DESTROY, CANCEL | none |
| RemovalBlock | Removal kind | Why a server cannot be removed now, as the provider's port reports it: RUNNING (a server that must be stopped first) or ALREADY_REMOVED (destroyed, or cancelled). | RUNNING, ALREADY_REMOVED | none |
| ServerRemovalPort | (provider) | The boundary for the removal of a server: its RemovalKind, whether a given server can be removed now, the consequence text, the one removal request, and the state of a removal operation; a narrow fourth port beside ProviderPort, ServerPowerPort and ServerProvisionPort ([ADR-0008]). | none | removalKind, removalBlock, consequence, requestRemoval, operationState (one read; polling belongs to the caller) |
| DesiredConfigurationStore | (configuration) | The boundary to the saved desired configurations; `save` replaces the one with the same key. | none | save, load, loadAll |
| ProvisionIntentStore | (configuration) | The boundary to the intents, kept apart from OperationStore (see the revision note). | none | save, load, findPending, loadByOperation |
| DesiredConfigurationValidator | Desired configuration | Checks a desired configuration against the provider's ValueRules and the ServerOptions it offers now; returns each problem and nothing else, so define and provision share one rule. | none | check |
| DefineDesiredConfiguration | Desired configuration | Realises UC-003: checks and saves a named desired configuration, re-checks a saved one and lists them; saves nothing that fails the check. | none | defineDesiredConfiguration, validateDesiredConfiguration, listDesiredConfigurations |
| ProvisionServer | Provision intent | Realises UC-004: previews with the cost consequence, and on confirmation saves the intent, sends one create request and records the operation; completes by recording the managed server when the operation succeeded and ending the intent. | none | previewProvisioning, requestProvisioning, completeProvisioning |
| RemoveServer | Operation | Realises UC-012: previews the removal kind and the consequence, and on confirmation (the identifier typed, and once more for an unmanaged server) sends one removal request and records the operation with the consequence; completes by ending the managed-server record when the operation succeeded. Never stops a server and sends nothing else. | none | previewRemoval, requestRemoval, completeRemoval |
| RemovalPreview | Consequence | What will happen, or why nothing can be removed: the outcome and reason, provider, configuration, server identifier and name, server state, whether it is managed, the removal kind and the consequence text. | outcome, reason, providerName, providerKind, configurationId, serverIdentifier, serverName, serverState, managed, kind, consequence | none |
| RemovalResult | Operation | Result of requesting or completing a removal: the outcome, the reason, the operation summary when one exists, the consequence recorded, the state left at the provider (for a cancellation the effective date reported) and whether the managed-server record was ended. | outcome, reason, operation, consequence, stateLeft, managedEnded | none |
| RemovalOutcome | Operation | The outcomes of a preview, a request and a completion: READY (preview offered), REQUESTED, COMPLETED (operation succeeded; managed record ended when there was one), INCOMPLETE (operation unfinished or unknown), REJECTED (provider refused, or the operation ended as failed), UNSUPPORTED, NOT_FOUND (no such server or operation), RUNNING_REFUSED, ALREADY_REMOVED, NOT_CONFIRMED, IDENTIFIER_MISMATCH. | READY, REQUESTED, COMPLETED, INCOMPLETE, REJECTED, UNSUPPORTED, NOT_FOUND, RUNNING_REFUSED, ALREADY_REMOVED, NOT_CONFIRMED, IDENTIFIER_MISMATCH | none |
| ControlServerPower | Operation | Realises UC-008: checks capability, state and confirmation, sends one request and records the operation; a preview does every check but the confirmation and sends nothing; refuses the actions PROVISION and REMOVE, which have their own use cases. | none | previewPowerAction, requestPowerAction |
| TrackOperation | Operation | Realises UC-006: follows an operation to its end and records the outcome; reads the configuration to build the provider, and uses the provision port's `operationState` for an operation whose action is PROVISION and the removal port's for REMOVE. | none | followOperation, showOperation |
| ConfigureProviderAccess | Provider configuration | Realises UC-001: validates access and saves a configuration; keeps the validated credentials in memory until the save or the next check, and never persists them. | none | validateAccess, saveProviderConfiguration |
| DiscoverCapabilities | Capability | Realises UC-002: discovers capabilities and options. | none | discoverCapabilities, listServerOptions |
| ListServers | Server | Realises UC-007: lists and inspects servers. | none | listServers, inspectServer |
| ProxmoxProvider | (provider) | Adapter for the Proxmox VE interface: the reads, the four power requests, the container and virtual machine creations and their deletion (`DESTROY`). | none | implements ProviderPort, ServerPowerPort, ServerProvisionPort, ServerRemovalPort |
| ContaboProvider | (provider) | Adapter for the Contabo interface (the reads, the four power requests, the instance creation and its cancellation, `CANCEL`): exchanges the four credential values for a bearer token kept in memory, sends a request identifier on every call and renews the token once after a 401. | none | implements ProviderPort, ServerPowerPort, ServerProvisionPort, ServerRemovalPort |
| JsonLinesConfigurationStore, JsonLinesOperationStore, JsonLinesDesiredConfigurationStore, JsonLinesProvisionIntentStore | (configuration) | Adapters that keep configuration and managed servers, operations, desired configurations and intents as JSON Lines in one file without secrets; each implements one port, because `save` and `loadAll` differ between the ports. | none | each implements its own port |
| PlatformCredentialStore | Credential reference | Adapter for the operating system credential store. | none | implements CredentialStore |
| ConsoleCredentialPrompt | (credentials) | Adapter that asks for each credential name of the provider on the console. | none | implements CredentialPrompt |
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
| ControlServerPower.previewPowerAction(configuration, serverIdentifier, action) : PowerActionResult | The checks of `requestPowerAction` in [OC-002] without the request; used by the client to state the action before it asks |
| ControlServerPower.requestPowerAction(configuration, serverIdentifier, action, confirmation) : PowerActionResult | `requestPowerAction` in [OC-002] and [SSD-004] |
| TrackOperation.followOperation(operationId, timeLimit, pollInterval) : OperationSummary | `followOperation` in [OC-003] and [SSD-005]; for REMOVE through `ServerRemovalPort.operationState` ([SSD-008]) |
| TrackOperation.showOperation(operationId) : OperationSummary | `showOperation` in [SSD-005] |
| ServerPowerPort.requestPower(configuration, serverIdentifier, action) | `requestPowerAction` in [OC-002] |
| ServerPowerPort.operationState(configuration, operation) | `followOperation` in [OC-003] |
| OperationStore.save(operation), load(operationId) | `requestPowerAction` in [OC-002], `followOperation` in [OC-003], and `requestRemoval` and `completeRemoval` in [OC-006] |
| DefineDesiredConfiguration.defineDesiredConfiguration(configuration, name, image, accessKeyNames, bootstrapHint, values) : DesiredConfigurationView | `defineDesiredConfiguration` in [OC-004] and [SSD-006] |
| DefineDesiredConfiguration.validateDesiredConfiguration(configuration, name) : DesiredConfigurationView | `validateDesiredConfiguration` in [OC-004] and [SSD-006] |
| DefineDesiredConfiguration.listDesiredConfigurations(configuration, check) : List | `listDesiredConfigurations` in [SSD-006] (a query; no contract) |
| DesiredConfigurationValidator.check(configuration, desiredConfiguration) : List | Supporting operation: the preconditions on the image and the values of `defineDesiredConfiguration` and `validateDesiredConfiguration` in [OC-004], and of `previewProvisioning` and `requestProvisioning` in [OC-005] |
| ProvisionServer.previewProvisioning(configuration, desiredName, serverName) : ProvisionPreview | `previewProvisioning` in [OC-005] and [SSD-007] |
| ProvisionServer.requestProvisioning(configuration, desiredName, serverName, confirmation) : ProvisionResult | `requestProvisioning` in [OC-005] and [SSD-007] |
| ProvisionServer.completeProvisioning(operationId) : ProvisionResult | `completeProvisioning` in [OC-005] and [SSD-007] |
| ServerProvisionPort.valueRules(configuration) | `defineDesiredConfiguration` in [OC-004] (the provider's required values and checks) |
| ServerProvisionPort.reserveIdentifier(configuration) | `requestProvisioning` in [OC-005] (the reserved identifier saved in the intent) |
| ServerProvisionPort.costConsequence(configuration, desiredConfiguration) | `previewProvisioning` in [OC-005] (the cost consequence) |
| ServerProvisionPort.requestProvision(configuration, desiredConfiguration, serverName, reservedIdentifier) | `requestProvisioning` in [OC-005] (the one create request) |
| ServerProvisionPort.operationState(configuration, operation) | `followOperation` in [OC-003] for an operation with action PROVISION |
| DesiredConfigurationStore.save(desiredConfiguration) | `defineDesiredConfiguration` in [OC-004] |
| DesiredConfigurationStore.load(configurationId, desiredName), loadAll(configurationId) | `validateDesiredConfiguration` in [OC-004], `listDesiredConfigurations` in [SSD-006], `previewProvisioning` and `requestProvisioning` in [OC-005] |
| ProvisionIntentStore.save(intent), load(intentId) | `requestProvisioning` and `completeProvisioning` in [OC-005] |
| ProvisionIntentStore.findPending(configurationId, serverName) | `previewProvisioning` and `requestProvisioning` in [OC-005] (the pending-intent precondition) |
| ProvisionIntentStore.loadByOperation(operationId) | `completeProvisioning` in [OC-005] |
| RemoveServer.previewRemoval(configuration, serverIdentifier) : RemovalPreview | `previewRemoval` in [OC-006] and [SSD-008] |
| RemoveServer.requestRemoval(configuration, serverIdentifier, confirmation) : RemovalResult | `requestRemoval` in [OC-006] and [SSD-008] |
| RemoveServer.completeRemoval(operationId) : RemovalResult | `completeRemoval` in [OC-006] and [SSD-008] |
| ServerRemovalPort.removalKind(configuration) | `previewRemoval` in [OC-006] (the Removal kind stated) |
| ServerRemovalPort.removalBlock(configuration, server) | `previewRemoval` and `requestRemoval` in [OC-006] (the running and already-removed exceptions) |
| ServerRemovalPort.consequence(configuration, server) | `previewRemoval` in [OC-006] (the Consequence text) and `requestRemoval` (recorded with the Operation) |
| ServerRemovalPort.requestRemoval(configuration, server) | `requestRemoval` in [OC-006] (the one removal request) |
| ServerRemovalPort.operationState(configuration, operation) | `followOperation` in [OC-003] for an operation with action REMOVE |
| ProviderResolver.removalFor(configuration) | Supporting operation of `previewRemoval`, `requestRemoval` and `completeRemoval` (credentials differ per configuration) |
| ConfigurationStore.saveManagedServer(record) | `completeProvisioning` in [OC-005] (the ManagedServerRecord) |
| ConfigurationStore.endManagedServer(configurationId, serverIdentifier, endedAt, operationId) | `completeRemoval` in [OC-006] (the Managed server ended) |
| ProviderResolver.provisionFor(configuration) | Supporting operation of `defineDesiredConfiguration`, `validateDesiredConfiguration`, `previewProvisioning`, `requestProvisioning` and `completeProvisioning` (credentials differ per configuration) |
| ProviderResolver.providerFor(configuration) | Supporting operation of `discoverCapabilities`, `listServerOptions`, `listServers`, `inspectServer`, `previewRemoval` and `requestRemoval` (credentials differ per configuration) |
| ProviderPort.validateAccess(address, credentials) | `validateAccess` in [SSD-001] |
| ProviderPort.discoverCapabilities(configuration) | `discoverCapabilities` in [SSD-002] |
| ProviderPort.listServerOptions(configuration, optionKind) | `listServerOptions` in [SSD-002] |
| ProviderPort.listServers(configuration) | `listServers` in [SSD-003] |
| ProviderPort.getServer(configuration, serverIdentifier) | `inspectServer` in [SSD-003]; `previewRemoval` and `requestRemoval` in [OC-006] (the server read first) |
| ConfigurationStore.save(configuration) | `saveProviderConfiguration` in [OC-001] |
| ConfigurationStore.loadAll(), managedServers(configurationId) | `listServers` in [SSD-003] (managed marking), `previewRemoval` and `requestRemoval` in [OC-006] (managed or not) and the configuration lookup of every message |
| CredentialStore.put(reference, credentials) | `saveProviderConfiguration` in [OC-001] (cacheCredential) |
| CredentialStore.get(reference) | `validateAccess` in [SSD-001] and `discoverCapabilities` in [SSD-002] (stored credentials) |
| CredentialPrompt.ask(providerKind) | `validateAccess` in [SSD-001] (credentials parameter) |

## Pattern Annotations

| Pattern | Classes | Rationale |
| --- | --- | --- |
| Ports and adapters | ProviderPort, ConfigurationStore, CredentialStore, CredentialPrompt and their adapters | Keeps the application free of provider, file and platform detail; a second provider is a new adapter ([ADR-0002]). |
| Composition root | CliApplication | The only place that names infrastructure classes. |
| Strategy | ProviderPort, ProxmoxProvider, ContaboProvider | Provider differences sit behind one interface; use cases do not test the provider kind ([ADR-0002]). |
| Interface segregation | ProviderPort, ServerPowerPort, ServerProvisionPort, ServerRemovalPort | Read-only code cannot reach a write by type; the write surface is the four power requests ([ADR-0006]), the create requests ([ADR-0007]) and the two removal requests ([ADR-0008]). |
| Write-ahead record | ProvisionIntent, ProvisionIntentStore, ProvisionServer | The intent is saved before the create request, so a lost answer leaves a pending intent that a retry meets ([ADR-0007]). |
| Data-driven validation | ValueRule, DesiredConfigurationValidator | Each provider declares its values as data; the validator holds one rule for every provider and use cases do not test the provider kind ([ADR-0002]). |
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
[ADR-0005]: ./adr/adr-0005-contabo-credentials-and-token.md
[OC-002]: ./use-cases/uc-008/oc.md
[OC-003]: ./use-cases/uc-006/oc.md
[SSD-004]: ./use-cases/uc-008/ssd.md
[SSD-005]: ./use-cases/uc-006/ssd.md
[ADR-0006]: ./adr/adr-0006-power-actions-and-operation-tracking.md
[ADR-0007]: ./adr/adr-0007-desired-configuration-and-provisioning.md
[UC-003]: ./use-cases/uc-003/uc.md
[UC-004]: ./use-cases/uc-004/uc.md
[SSD-006]: ./use-cases/uc-003/ssd.md
[SSD-007]: ./use-cases/uc-004/ssd.md
[OC-004]: ./use-cases/uc-003/oc.md
[OC-005]: ./use-cases/uc-004/oc.md
[ADR-0008]: ./adr/adr-0008-removal-of-a-server.md
[UC-012]: ./use-cases/uc-012/uc.md
[SSD-008]: ./use-cases/uc-012/ssd.md
[OC-006]: ./use-cases/uc-012/oc.md
[9a23c07]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/9a23c07674d4681e2dc709d3839956aea75e2298
