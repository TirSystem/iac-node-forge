# Design Class Diagram

## Metadata
| Key | Value |
| --- | --- |
| ID | DCD-001 |
| CrossReference | [DM-001], [OC-001], [OC-002], [OC-003], [SSD-001], [SSD-002], [SSD-003], [SSD-004], [SSD-005], [DICT-001], [ADR-0002], [ADR-0005], [ADR-0006], [ADR-0007], [SSD-006], [SSD-007], [OC-004], [OC-005], [ADR-0008], [SSD-008], [OC-006], [ADR-0001], [ADR-0009], [SSD-009], [OC-007], [SSD-010], [OC-008], [ADR-0010], [SSD-011], [OC-009], [SSD-012], [OC-010] |

## Version History
| Date | Status | Author | Reviewer | Change | Commit |
| --- | --- | --- | --- | --- | --- |
| 2026-10-25 | Deprecated | Jens Tirsvad Nielsen | AI as stand-in for S02 | Revision 12: ServerBackupPort, BackupStore, BackUpServer, ListBackups, RestoreServer; Backup, BackupKind, BackupRecord, RestoreEffect, BackupBlock and their DTOs and outcomes; PowerAction gains BACKUP and RESTORE (MIL-008)<br>Accepted after RC-118 | [9fd15f2] |
| 2026-10-25 | Accepted | Jens Tirsvad Nielsen | AI as stand-in for S02 | Revision 13: aligned with the built whole-server backup code (MIL-008 task 12)<br>Accepted after RC-122 | pending |

---

## Purpose and Scope

The design classes that realise the system operations of [SSD-001], [SSD-002] and
[SSD-003] and the contract of [OC-001], arranged in the layers of the clean
architecture: `domain`, `application`, `infrastructure` and `presentation`. Names are the
IT terms of [DICT-001], in the language-neutral spelling; each language applies its own
naming convention. Dependencies point inward: `application` depends on `domain`;
`infrastructure` and `presentation` depend on `application` and `domain`.

Revised after the code of MIL-008 on 2026-10-25 (revision 13): the DTOs of the backup are in their own module; the
adapters check the block again before they write a restore, and a restore that the block forbids ends as a failed
operation without any request; at Contabo a restore or backup of an instance that is `stopped` succeeds as well as
one that is `running`, a 404 on a restore ends as a failed operation (a missing snapshot and a missing instance
cannot be told apart), a snapshot without a creation date is left out of the listing, and the list of newer snapshots
in the consequence names three and then counts the rest; `RestoreResult.stateAfter` is the state word, and the state
read after a restore is also put at the start of the operation's detail; the typed-identifier and not-confirmed
handling is shared with the removal ([ADR-0010]).

Revised for MIL-008 on 2026-10-25 (revision 12): the write side grows by the backup and restore of a whole
server ([ADR-0010]). `ServerBackupPort` is a fifth narrow port beside `ProviderPort`, `ServerPowerPort`,
`ServerProvisionPort` and `ServerRemovalPort`; it states its `BackupKind` (`ARCHIVE` at Proxmox VE, `SNAPSHOT` at
Contabo), lists the storages that accept backups, says through `BackupBlock` whether a backup or a restore can be
made now (no backup storage, storage unsuitable, running, cancelled, wrong kind of guest), gives the consequence
of a backup and the `RestoreEffect` of a restore (the text and the backups it deletes), sends the one backup or
the one restore request, lists the backups of a server, finds the backup an operation made and reads the state
of its operation. The use cases `BackUpServer`, `ListBackups` and `RestoreServer` realise [UC-018] and
[UC-019] with `previewBackup`, `requestBackup`, `completeBackup`, `listBackups`, `previewRestore`,
`requestRestore` and `completeRestore`. The action of an `Operation` gains `BACKUP` and `RESTORE` (the type
keeps the name `PowerAction`; `ControlServerPower` refuses both); `TrackOperation` reads them through
`ProviderResolver.backupFor`. A `BackupRecord` says where a backup that this client made is kept; it has its
own port `BackupStore` and its own adapter because it has its own key and its own reason to change, and it is
written by `completeBackup` once the provider lists the backup. The provider is the authority for the list
(`listBackups` merges the records into it). The names `previewBackup`, `requestBackup`, `previewRestore` and
`requestRestore` are also operations of `BackUpFiles` and `RestoreFiles` (revision 10); they are different
classes with different contracts ([OC-007], [OC-008] and [OC-009], [OC-010]).

Revised after the code of MIL-007 on 2026-10-20 (revision 11): `AccessResolution` also carries the
`configuration`, so that the previews can name the provider and the configuration; the transfer DTOs are in
their own module; `CliServices` holds the transfer adapters as one group; the local checks (path syntax, an
empty destination) run before the resolver, so they are reported without a connection; a backup of `/`, or
of nested or duplicate paths, is `INVALID_PATH`; a link that the pull refuses is left out of the comparison
and listed; a restore fails only on a missing or changed file and reports the files left in place, so a
verified `TransferReport` may list `EXTRA` differences ([ADR-0009] revision 2).

Revised for MIL-007 on 2026-10-18 (revision 10): the product reaches the inside of a server
([ADR-0009]). The use cases `BackUpFiles` and `RestoreFiles` realise [UC-016] and [UC-017] with
`previewBackup`, `requestBackup`, `previewRestore` and `requestRestore`, and `DefineServerAccess` records the
connection facts with `defineServerAccess`. There is no operation to follow: a transfer runs to its end
inside the call and returns a `TransferResult` with a `TransferReport`, so `Operation`, `OperationStore`,
`TrackOperation` and the provider write ports are not used. The boundary to the server is four narrow
ports, each with one reason to change: `RemoteReadPort` (the reads on the server: host key check, size,
manifest, existing data), `FileTransferPort` (the two tar streams, `pull` and `push`), `KnownHostsPort`
(the one write to the user's own `known_hosts`, on an explicit acceptance) and `LocalFilesystemPort` (room,
local manifests, the check of the destination and the report file). The reads are kept apart from the
streams so that the checks of the host key, the size and the manifest have no way to write; the fakes record
every remote command, so a test shows that a backup ran only reads and one `tar -c`. `ServerAccessStore` keeps the `ServerAccess` of a server in the existing file; `ServerAccess` is
what is kept (the host may be empty) and `RemoteAccess` is what one run uses (the host resolved from the
record or from `Server.addresses`). `RemoteAccessResolver` is the one place that checks the server, its
state, the recorded access, the address and the host key for both use cases, so the rules are written once.
The accepted fingerprint is a parameter of the preview, not an operation of its own: the preview is where
the connection is first made. The adapters are `OpenSshRemoteReader`, `OpenSshFileTransfer` and
`OpenSshKnownHosts`, which build their commands only through `OpenSshCommands` (the allow-list), the
`LocalDiskFilesystem` and `JsonLinesServerAccessStore`; in-process fakes for the same ports serve the contract
suite and the unit tests. The `Confirmation` of a restore is the one of a removal.

Revised after the code of MIL-006 on 2026-10-18 (revision 9): the flag of `Confirmation` is named `given`, as it
was for the power and provisioning requests; the adapters leave `Operation.consequence` empty and the use case
records the text shown in the preview; `completeRemoval` ends only an active managed record recorded at or
before the start of the operation, so that completing a removal again cannot end a newer server that reuses
a Proxmox VE identifier; for a blocked server (running, already removed) the preview shows the server and
no consequence line ([ADR-0008]).

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
    BACKUP
    RESTORE
  }
  enum BackupKind {
    ARCHIVE
    SNAPSHOT
  }
  class Backup {
    - backupId : Text
    - kind : BackupKind
    - location : Text
    - createdAt : Timestamp
    - sizeBytes : Integer [0..1]
    - label : Text [0..1]
    - guestType : Text [0..1]
    - madeByClient : Boolean
    - autoDeleteAt : Timestamp [0..1]
    + alias() : Text
  }
  class RestoreEffect {
    - consequence : Text
    - deletedBackups : List
  }
  class BackupRecord {
    - configurationId : ConfigurationId
    - serverIdentifier : Text
    - backupId : Text
    - kind : BackupKind
    - location : Text
    - createdAt : Timestamp
    - operationId : OperationId
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
  class ServerAccess {
    - configurationId : ConfigurationId
    - serverIdentifier : Text
    - host : Text [0..1]
    - port : Integer
    - user : Text
    - identityHint : Text [0..1]
  }
  class RemoteAccess {
    - host : Text
    - port : Integer
    - user : Text
    - identityHint : Text [0..1]
  }
  class HostKey {
    - host : Text
    - port : Integer
    - keyType : Text
    - fingerprint : Text
  }
  enum HostKeyStanding {
    KNOWN
    UNKNOWN
    CHANGED
  }
  class HostKeyCheck {
    - standing : HostKeyStanding
    - hostKey : HostKey [0..1]
  }
  enum TransferDirection {
    BACKUP
    RESTORE
  }
  enum EntryKind {
    FILE
    LINK
  }
  class ManifestEntry {
    - path : Text
    - kind : EntryKind
    - size : Integer
    - checksum : Text [0..1]
    - linkTarget : Text [0..1]
  }
  class Manifest {
    - entries : List
  }
  enum DifferenceKind {
    MISSING
    EXTRA
    CHANGED
  }
  class ManifestDifference {
    - path : Text
    - kind : DifferenceKind
  }
  class OverwriteEntry {
    - path : Text
    - size : Integer
    - modifiedAt : Timestamp
  }
  class SkippedEntry {
    - path : Text
    - reason : Text
  }
  class TransferReport {
    - direction : TransferDirection
    - configurationId : ConfigurationId
    - serverIdentifier : Text
    - startedAt : Timestamp
    - finishedAt : Timestamp
    - fileCount : Integer
    - linkCount : Integer
    - byteCount : Integer
    - skipped : List
    - overwritten : List
    - differences : List
    - verified : Boolean
    - note : Text [0..1]
    - reportFile : Text [0..1]
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
  enum BackupBlock {
    NO_BACKUP_STORAGE
    STORAGE_UNSUITABLE
    RUNNING
    CANCELLED
    MISMATCH
  }
  interface ServerBackupPort {
    + backupKind(configuration) : BackupKind
    + backupStorages(configuration, server) : List
    + backupBlock(configuration, server, storage) : BackupBlock [0..1]
    + restoreBlock(configuration, server, backup) : BackupBlock [0..1]
    + backupConsequence(configuration, server, storage) : Text
    + restoreEffect(configuration, server, backup) : RestoreEffect
    + requestBackup(configuration, server, storage) : Operation
    + requestRestore(configuration, server, backup) : Operation
    + listBackups(configuration, server) : List
    + findBackup(configuration, operation) : Backup [0..1]
    + operationState(configuration, operation) : Operation
  }
  interface BackupStore {
    + save(record) : void
    + load(configurationId, serverIdentifier, backupId) : BackupRecord [0..1]
    + loadFor(configurationId, serverIdentifier) : List
    + loadByOperation(operationId) : BackupRecord [0..1]
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
    + backupFor(configuration) : ServerBackupPort
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
  class BackUpServer {
    + previewBackup(configuration, serverIdentifier, storage) : BackupPreview
    + requestBackup(configuration, serverIdentifier, storage, confirmation) : BackupResult
    + completeBackup(operationId) : BackupResult
  }
  class ListBackups {
    + listBackups(configuration, serverIdentifier) : BackupListing
  }
  class RestoreServer {
    + previewRestore(configuration, serverIdentifier, backupId) : RestorePreview
    + requestRestore(configuration, serverIdentifier, backupId, confirmation) : RestoreResult
    + completeRestore(operationId) : RestoreResult
  }
  enum BackupOutcome {
    READY
    REQUESTED
    COMPLETED
    INCOMPLETE
    REJECTED
    UNSUPPORTED
    NOT_FOUND
    STORAGE_REQUIRED
    NO_BACKUP_STORAGE
    STORAGE_UNSUITABLE
    NOT_AVAILABLE
    NOT_CONFIRMED
    LISTED
  }
  enum RestoreOutcome {
    READY
    REQUESTED
    COMPLETED
    INCOMPLETE
    REJECTED
    UNSUPPORTED
    NOT_FOUND
    BACKUP_NOT_FOUND
    BACKUP_MISMATCH
    RUNNING_REFUSED
    NOT_AVAILABLE
    NOT_CONFIRMED
    IDENTIFIER_MISMATCH
  }
  class BackupPreview
  class BackupResult
  class BackupSummary
  class BackupListing
  class RestorePreview
  class RestoreResult
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
  interface RemoteReadPort {
    + checkHostKey(access) : HostKeyCheck
    + totalSize(access, paths) : Integer
    + manifest(access, root, relativePaths) : Manifest
    + existing(access, root, names) : List
  }
  interface FileTransferPort {
    + pull(access, remotePaths, destination) : List
    + push(access, localPaths, remoteDestination) : List
  }
  interface KnownHostsPort {
    + trust(hostKey) : void
  }
  interface LocalFilesystemPort {
    + freeBytes(directory) : Integer
    + isNewOrEmpty(directory) : Boolean
    + missing(paths) : List
    + size(paths) : Integer
    + manifestOfPaths(paths) : Manifest
    + manifestUnder(directory, relativePaths) : Manifest
    + saveReport(directory, report) : Text
  }
  interface ServerAccessStore {
    + save(access) : void
    + load(configurationId, serverIdentifier) : ServerAccess [0..1]
  }
  class RemoteAccessResolver {
    + resolve(configuration, serverIdentifier, acceptedFingerprint) : AccessResolution
  }
  class DefineServerAccess {
    + defineServerAccess(configuration, serverIdentifier, host, port, user, identityHint) : ServerAccessView
  }
  class BackUpFiles {
    + previewBackup(configuration, serverIdentifier, remotePaths, destination, acceptedFingerprint) : TransferPreview
    + requestBackup(configuration, serverIdentifier, remotePaths, destination) : TransferResult
  }
  class RestoreFiles {
    + previewRestore(configuration, serverIdentifier, localPaths, remoteDestination, acceptedFingerprint) : TransferPreview
    + requestRestore(configuration, serverIdentifier, localPaths, remoteDestination, reportDirectory, confirmation) : TransferResult
  }
  enum TransferOutcome {
    READY
    COMPLETED
    VERIFICATION_FAILED
    TRANSFER_FAILED
    HOST_KEY_UNKNOWN
    HOST_KEY_CHANGED
    CONNECTION_FAILED
    ACCESS_MISSING
    SERVER_NOT_FOUND
    SERVER_NOT_RUNNING
    PATH_NOT_FOUND
    INVALID_PATH
    DESTINATION_NOT_EMPTY
    NO_ROOM
    NOT_CONFIRMED
    IDENTIFIER_MISMATCH
  }
  enum AccessOutcome {
    SAVED
    INVALID
    NOT_FOUND
  }
  class AccessResolution
  class ServerAccessView
  class TransferPreview
  class TransferResult
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
  class OpenSshCommands
  class OpenSshRemoteReader
  class OpenSshFileTransfer
  class OpenSshKnownHosts
  class LocalDiskFilesystem
  class JsonLinesServerAccessStore
  class JsonLinesBackupStore
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
ProxmoxProvider ..|> ServerBackupPort
ContaboProvider ..|> ServerBackupPort
ProviderResolver ..> ServerBackupPort
ServerBackupPort ..> BackupKind
ServerBackupPort ..> BackupBlock
ServerBackupPort ..> Backup
ServerBackupPort ..> RestoreEffect
BackUpServer ..> ProviderResolver
BackUpServer ..> OperationStore
BackUpServer ..> BackupStore
BackUpServer ..> ConfigurationStore
ListBackups ..> ProviderResolver
ListBackups ..> BackupStore
ListBackups ..> ConfigurationStore
RestoreServer ..> ProviderResolver
RestoreServer ..> OperationStore
RestoreServer ..> ConfigurationStore
BackupStore ..> BackupRecord
JsonLinesBackupStore ..|> BackupStore
Backup "0..*" --> "1" BackupKind
BackupRecord "0..*" --> "1" BackupKind
BackupRecord "0..*" --> "1" ProviderConfiguration
BackupRecord "0..*" --> "1" Operation
RestoreEffect "1" --> "0..*" Backup
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
CliApplication ..> BackUpServer
CliApplication ..> ListBackups
CliApplication ..> RestoreServer
CliApplication ..> ControlServerPower
CliApplication ..> TrackOperation
CliApplication ..> CredentialPrompt
CliApplication ..> DefineServerAccess
CliApplication ..> BackUpFiles
CliApplication ..> RestoreFiles
CliProviderResolver ..|> ProviderResolver
CliApplication ..> CredentialSource
CredentialSource ..> CredentialStore
CredentialSource ..> CredentialPrompt
ServerAccess "0..*" --> "1" ProviderConfiguration
HostKeyCheck "0..*" --> "1" HostKeyStanding
HostKeyCheck "0..*" --> "0..1" HostKey
Manifest "1" *-- "0..*" ManifestEntry
ManifestEntry "0..*" --> "1" EntryKind
ManifestDifference "0..*" --> "1" DifferenceKind
TransferReport "1" *-- "0..*" ManifestDifference
TransferReport "1" *-- "0..*" OverwriteEntry
TransferReport "1" *-- "0..*" SkippedEntry
TransferReport "0..*" --> "1" TransferDirection
RemoteReadPort ..> RemoteAccess
RemoteReadPort ..> HostKeyCheck
RemoteReadPort ..> Manifest
RemoteReadPort ..> OverwriteEntry
FileTransferPort ..> RemoteAccess
FileTransferPort ..> SkippedEntry
KnownHostsPort ..> HostKey
LocalFilesystemPort ..> Manifest
LocalFilesystemPort ..> TransferReport
ServerAccessStore ..> ServerAccess
RemoteAccessResolver ..> ProviderResolver
RemoteAccessResolver ..> ConfigurationStore
RemoteAccessResolver ..> ServerAccessStore
RemoteAccessResolver ..> RemoteReadPort
RemoteAccessResolver ..> KnownHostsPort
DefineServerAccess ..> ProviderResolver
DefineServerAccess ..> ConfigurationStore
DefineServerAccess ..> ServerAccessStore
BackUpFiles ..> RemoteAccessResolver
BackUpFiles ..> RemoteReadPort
BackUpFiles ..> FileTransferPort
BackUpFiles ..> LocalFilesystemPort
BackUpFiles ..> ConfigurationStore
RestoreFiles ..> RemoteAccessResolver
RestoreFiles ..> RemoteReadPort
RestoreFiles ..> FileTransferPort
RestoreFiles ..> LocalFilesystemPort
RestoreFiles ..> ConfigurationStore
OpenSshRemoteReader ..|> RemoteReadPort
OpenSshFileTransfer ..|> FileTransferPort
OpenSshKnownHosts ..|> KnownHostsPort
LocalDiskFilesystem ..|> LocalFilesystemPort
JsonLinesServerAccessStore ..|> ServerAccessStore
OpenSshRemoteReader ..> OpenSshCommands
OpenSshFileTransfer ..> OpenSshCommands
OpenSshKnownHosts ..> OpenSshCommands
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
| Capability | Capability | Names one supported action or option, for example `list_servers`, the four power actions, `provision_server`, `remove_server`, `backup_server` and `restore_server`. | name | none |
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
| ProviderResolver | (provider) | Gives the provider port, the power port, the provision port, the removal port and the backup port for one saved configuration, built with that configuration's credentials. | none | providerFor, powerFor, provisionFor, removalFor, backupFor |
| AccessCheck, SavedConfiguration, CapabilityReport, ServerSummary, ServerListing, ProviderFailure, OperationSummary, PowerActionResult | (result types) | Data transfer objects that cross from the use cases to presentation so no domain entity does. | outcome, reason, entries, failures | none |
| Confirmation | Consequence | What the user gave before a request is sent: `given`, and for a removal the identifier typed (`typedIdentifier`) and, for a server not managed by this client, the identifier typed again (`unmanagedIdentifier`). | given, typedIdentifier, unmanagedIdentifier | none |
| DesiredConfigurationView | Desired configuration | Result of defining, validating or listing a desired configuration: its name, configuration, image, access key names, bootstrap hint, values, whether it is valid and each problem. | configurationId, name, image, accessKeyNames, bootstrapHint, values, valid, problems | none |
| ProvisionPreview | Provision intent | What will be created, or why nothing can be: the outcome and reason, provider, configuration, desired name, server name, target, image, size, values and the cost consequence text (empty when the provider imposes none). | outcome, reason, providerName, providerKind, configurationId, desiredName, serverName, target, image, size, values, costConsequence | none |
| ProvisionResult | Operation | Result of requesting or completing a provisioning: the outcome, the reason, the operation summary when one exists, the server identifier when known, and the state left at the provider. | outcome, reason, operation, serverIdentifier, stateLeft | none |
| ProvisionOutcome | Operation | The outcomes of a preview, a request and a completion: READY (preview offered), REQUESTED, COMPLETED (server recorded as managed), INCOMPLETE (operation unfinished, unknown or without a server identifier), REJECTED (provider refused, or the operation ended as failed), UNSUPPORTED, INVALID, NAME_EXISTS, INTENT_PENDING, NOT_CONFIRMED. | READY, REQUESTED, COMPLETED, INCOMPLETE, REJECTED, UNSUPPORTED, INVALID, NAME_EXISTS, INTENT_PENDING, NOT_CONFIRMED | none |
| PowerAction, OperationState | Operation | The four power actions plus PROVISION, REMOVE, BACKUP and RESTORE, the kind of an operation (the type keeps its name; `requestPowerAction` refuses PROVISION, REMOVE, BACKUP and RESTORE), and the four states of an operation. | START, SHUTDOWN, STOP, RESTART, PROVISION, REMOVE, BACKUP, RESTORE; RUNNING, SUCCEEDED, FAILED, UNKNOWN | none |
| Operation | Operation | One requested action and its recorded outcome; never holds a secret. `serverIdentifier`, `finishedAt`, `providerReference` and `detail` are empty until set (`serverIdentifier` for a provision operation until the provider names the server); `detail` is bounded to 500 characters. For a removal, a backup or a restore, `consequence` (bounded to 500 characters, empty for every other action) is the text shown before the confirmation, kept as shown; `detail` holds the outcome and, for a cancellation, the effective date the provider reports, and for a restore the state of the server read afterwards. `providerReference` holds the task identifier (Proxmox VE) or the snapshot identifier (Contabo). | operationId, configurationId, serverIdentifier, action, state, startedAt, finishedAt, providerReference, detail, consequence | none |
| ServerPowerPort | (provider) | The boundary for the four power requests and for reading an operation's state; a narrow port beside ProviderPort ([ADR-0006]). | none | requestPower, operationState (one read; returns the operation updated, polling belongs to the caller) |
| OperationStore | (configuration) | The boundary to the record of operations. | none | save, load |
| ServerProvisionPort | (provider) | The boundary for the creation of a server: the provider's ValueRules, the reserved identifier (Proxmox VE `nextid`; empty for Contabo), the cost consequence text, the one create request, and the state of a provision operation; a narrow third port beside ProviderPort and ServerPowerPort ([ADR-0007]). | none | valueRules, reserveIdentifier, costConsequence, requestProvision, operationState |
| RemovalKind | Removal kind | The two ways a provider ends a server: DESTROY (now, disks released; Proxmox VE) and CANCEL (a request with an effective date reported by the provider, the contract running on until then; Contabo). | DESTROY, CANCEL | none |
| RemovalBlock | Removal kind | Why a server cannot be removed now, as the provider's port reports it: RUNNING (a server that must be stopped first) or ALREADY_REMOVED (destroyed, or cancelled). | RUNNING, ALREADY_REMOVED | none |
| ServerRemovalPort | (provider) | The boundary for the removal of a server: its RemovalKind, whether a given server can be removed now, the consequence text, the one removal request, and the state of a removal operation; a narrow fourth port beside ProviderPort, ServerPowerPort and ServerProvisionPort ([ADR-0008]). | none | removalKind, removalBlock, consequence, requestRemoval, operationState (one read; polling belongs to the caller) |
| BackupKind | Backup kind | The two ways a provider keeps a backup: ARCHIVE (a file on a storage that accepts backups; Proxmox VE) and SNAPSHOT (held by the provider on the same disk system as the server, not an independent copy; Contabo). | ARCHIVE, SNAPSHOT | none |
| Backup | Backup | One backup of a server as the provider reports it: the provider-specific identifier (a Proxmox VE `volid`, a Contabo `snapshotId`), kind, location, creation time, size where known, a label (the first line of the notes of an archive, the name of a snapshot), the type of guest for an archive (`lxc` or `qemu`), whether this client made it (the marker in the notes, or the name prefix `iacnf-`) and the time at which the provider deletes it where it says so. `alias` is derived, not stored: the first eight hexadecimal characters of the SHA-256 of `backupId`. Never holds a secret. | backupId, kind, location, createdAt, sizeBytes, label, guestType, madeByClient, autoDeleteAt | alias |
| RestoreEffect | Restore effect | What a restore does, as the port states it before anything is sent: the consequence text and the backups the restore deletes (the snapshots newer than the chosen one for SNAPSHOT; empty for ARCHIVE). | consequence, deletedBackups | none |
| BackupRecord | Backup | A backup that this client made, recorded when the backup operation succeeded and the provider listed the backup; unique by (configurationId, serverIdentifier, backupId), linked to the operation that made it. Never deleted by this client and never holds a secret. | configurationId, serverIdentifier, backupId, kind, location, createdAt, operationId | none |
| BackupBlock | Backup kind | Why a backup or a restore cannot be made now, as the port reports it: NO_BACKUP_STORAGE (no storage accepts backups), STORAGE_UNSUITABLE (the storage named does not exist, does not accept backups, or the provider has no storage), RUNNING (a Proxmox VE guest that must be stopped before a restore), CANCELLED (a cancelled or otherwise unavailable server) and MISMATCH (a backup of another type of guest). | NO_BACKUP_STORAGE, STORAGE_UNSUITABLE, RUNNING, CANCELLED, MISMATCH | none |
| ServerBackupPort | (provider) | The boundary for the backup and restore of a whole server: its BackupKind, the storages that accept backups, whether a backup or a restore can be made now, the consequence of a backup, the RestoreEffect, the one backup request (the operation identifier goes into the marker or description), the one restore request, the provider's list of backups of a server, the backup an operation made, and the state of a backup or restore operation; a narrow fifth port beside ProviderPort, ServerPowerPort, ServerProvisionPort and ServerRemovalPort ([ADR-0010]). | none | backupKind, backupStorages, backupBlock, restoreBlock, backupConsequence, restoreEffect, requestBackup, requestRestore, listBackups, findBackup, operationState (one read; polling belongs to the caller) |
| BackupStore | Backup | The boundary to the records of backups; `save` replaces the one with the same key. | none | save, load, loadFor, loadByOperation |
| BackUpServer | Operation | Realises UC-018: previews the kind, the place and the consequence of a backup (choosing the only storage that accepts backups when none is named), and on a plain confirmation sends one backup request and records the operation with the consequence; completes by locating the backup at the provider and recording it. Changes nothing on the server and sends nothing else. | none | previewBackup, requestBackup, completeBackup |
| ListBackups | Backup | Realises the choice of a backup in UC-019: reads the provider's backups of a server, marks the ones this client made, merges the records (the operation that made each) and lists the recorded backups the provider no longer lists. Sends no write request. | none | listBackups |
| RestoreServer | Operation | Realises UC-019: previews the restore effect (resolving the backup from its identifier or its alias), and on confirmation (the identifier typed, and once more for an unmanaged server) sends one restore request and records the operation with the consequence; completes by reading and recording the state of the server. Refuses a running Proxmox VE guest and never stops it. | none | previewRestore, requestRestore, completeRestore |
| BackupOutcome | Operation | The outcomes of a backup preview, request, completion and listing: READY, REQUESTED, COMPLETED (operation succeeded and the backup recorded), INCOMPLETE (operation unfinished, unknown, or succeeded without the backup being located), REJECTED (provider refused, or the operation ended as failed), UNSUPPORTED, NOT_FOUND, STORAGE_REQUIRED (several storages accept backups and none was named), NO_BACKUP_STORAGE, STORAGE_UNSUITABLE, NOT_AVAILABLE, NOT_CONFIRMED, LISTED. | READY, REQUESTED, COMPLETED, INCOMPLETE, REJECTED, UNSUPPORTED, NOT_FOUND, STORAGE_REQUIRED, NO_BACKUP_STORAGE, STORAGE_UNSUITABLE, NOT_AVAILABLE, NOT_CONFIRMED, LISTED | none |
| RestoreOutcome | Operation | The outcomes of a restore preview, request and completion: READY, REQUESTED, COMPLETED (operation succeeded and the state of the server read), INCOMPLETE (operation unfinished or unknown), REJECTED, UNSUPPORTED, NOT_FOUND (no such server or operation), BACKUP_NOT_FOUND (not listed, or an alias that is not unique), BACKUP_MISMATCH, RUNNING_REFUSED, NOT_AVAILABLE, NOT_CONFIRMED, IDENTIFIER_MISMATCH. | READY, REQUESTED, COMPLETED, INCOMPLETE, REJECTED, UNSUPPORTED, NOT_FOUND, BACKUP_NOT_FOUND, BACKUP_MISMATCH, RUNNING_REFUSED, NOT_AVAILABLE, NOT_CONFIRMED, IDENTIFIER_MISMATCH | none |
| BackupSummary | Backup | A Backup as shown: identifier, alias, kind, location, creation time, size, label, whether this client made it, the operation that made it (from the record) and the auto-delete time. | backupId, alias, kind, location, createdAt, sizeBytes, label, madeByClient, operationId, autoDeleteAt | none |
| BackupPreview | Consequence | What a backup will do, or why nothing can be made: the outcome and reason, provider, configuration, server (identifier, name, state), kind, the storage chosen, the storages offered when one must be chosen, where it will be kept and the consequence text. | outcome, reason, providerName, providerKind, configurationId, serverIdentifier, serverName, serverState, kind, storage, storages, location, consequence | none |
| BackupResult | Operation | Result of requesting or completing a backup: the outcome, the reason, the operation summary when one exists, the consequence recorded, the backup (as a BackupSummary) when it was located, whether it was recorded and the state left at the provider. | outcome, reason, operation, consequence, backup, recorded, stateLeft | none |
| BackupListing | Backup | Result of `listBackups`: the outcome and reason, provider, configuration, server, kind, the backups the provider lists and the recorded backups it no longer lists. | outcome, reason, providerName, configurationId, serverIdentifier, kind, backups, goneFromProvider | none |
| RestorePreview | Restore effect | What a restore will do, or why it cannot: the outcome and reason, provider, configuration, server (identifier, name, state), whether it is managed, the backup, the consequence text and the backups the restore deletes. | outcome, reason, providerName, providerKind, configurationId, serverIdentifier, serverName, serverState, managed, backup, consequence, deletedBackups | none |
| RestoreResult | Operation | Result of requesting or completing a restore: the outcome, the reason, the operation summary when one exists, the consequence recorded and the state of the server afterwards. | outcome, reason, operation, consequence, stateAfter | none |
| DesiredConfigurationStore | (configuration) | The boundary to the saved desired configurations; `save` replaces the one with the same key. | none | save, load, loadAll |
| ProvisionIntentStore | (configuration) | The boundary to the intents, kept apart from OperationStore (see the revision note). | none | save, load, findPending, loadByOperation |
| DesiredConfigurationValidator | Desired configuration | Checks a desired configuration against the provider's ValueRules and the ServerOptions it offers now; returns each problem and nothing else, so define and provision share one rule. | none | check |
| DefineDesiredConfiguration | Desired configuration | Realises UC-003: checks and saves a named desired configuration, re-checks a saved one and lists them; saves nothing that fails the check. | none | defineDesiredConfiguration, validateDesiredConfiguration, listDesiredConfigurations |
| ProvisionServer | Provision intent | Realises UC-004: previews with the cost consequence, and on confirmation saves the intent, sends one create request and records the operation; completes by recording the managed server when the operation succeeded and ending the intent. | none | previewProvisioning, requestProvisioning, completeProvisioning |
| RemoveServer | Operation | Realises UC-012: previews the removal kind and the consequence, and on confirmation (the identifier typed, and once more for an unmanaged server) sends one removal request and records the operation with the consequence; completes by ending the managed-server record when the operation succeeded. Never stops a server and sends nothing else. | none | previewRemoval, requestRemoval, completeRemoval |
| RemovalPreview | Consequence | What will happen, or why nothing can be removed: the outcome and reason, provider, configuration, server identifier and name, server state, whether it is managed, the removal kind and the consequence text. | outcome, reason, providerName, providerKind, configurationId, serverIdentifier, serverName, serverState, managed, kind, consequence | none |
| RemovalResult | Operation | Result of requesting or completing a removal: the outcome, the reason, the operation summary when one exists, the consequence recorded, the state left at the provider (for a cancellation the effective date reported) and whether the managed-server record was ended. | outcome, reason, operation, consequence, stateLeft, managedEnded | none |
| RemovalOutcome | Operation | The outcomes of a preview, a request and a completion: READY (preview offered), REQUESTED, COMPLETED (operation succeeded; managed record ended when there was one), INCOMPLETE (operation unfinished or unknown), REJECTED (provider refused, or the operation ended as failed), UNSUPPORTED, NOT_FOUND (no such server or operation), RUNNING_REFUSED, ALREADY_REMOVED, NOT_CONFIRMED, IDENTIFIER_MISMATCH. | READY, REQUESTED, COMPLETED, INCOMPLETE, REJECTED, UNSUPPORTED, NOT_FOUND, RUNNING_REFUSED, ALREADY_REMOVED, NOT_CONFIRMED, IDENTIFIER_MISMATCH | none |
| ServerAccess | Server access | The non-secret connection facts kept for one server, unique by (configurationId, serverIdentifier): the host (empty: the address the provider reports is used at the time of a transfer), the port (22 by default), the user (required, no default), and an identity hint (a key file path or a note, at most 500 characters; passed to `ssh` as `-i` only when it names an existing file). Never holds a password, a passphrase, a key or a token ([ADR-0009]). | configurationId, serverIdentifier, host, port, user, identityHint | none |
| RemoteAccess | Server access | What one run uses to connect: the host resolved from the record or from `Server.addresses` (without a prefix length), the port, the user and the identity hint; built by `RemoteAccessResolver`, never persisted. | host, port, user, identityHint | none |
| HostKey | Host key | The key a server shows: the host and port, the key type and the fingerprint (`SHA256:...`). | host, port, keyType, fingerprint | none |
| HostKeyStanding, HostKeyCheck | Host key | Whether the user trusts the key shown: KNOWN (a scanned key matches `known_hosts`), UNKNOWN (no entry for the host) or CHANGED (an entry exists and no scanned key matches), and the result of a check with the key shown. | KNOWN, UNKNOWN, CHANGED; standing, hostKey | none |
| TransferDirection, EntryKind, DifferenceKind | Transfer | The direction of a transfer (BACKUP, RESTORE), the kind of a manifest entry (FILE, LINK) and the kind of a difference found by the verification (MISSING, EXTRA, CHANGED). | BACKUP, RESTORE; FILE, LINK; MISSING, EXTRA, CHANGED | none |
| ManifestEntry, Manifest | Manifest | The entries of the data of a transfer: for a file its path (relative to the destination), size and SHA-256 checksum, for a link its path and target; two entries are equal when path, kind, size, checksum and target are equal. Modes and owners are not part of it. The use cases compare two manifests entry by entry and make the ManifestDifferences. | path, kind, size, checksum, linkTarget; entries | none |
| ManifestDifference | Manifest | One difference between the manifest at the source and at the destination. | path, kind | none |
| OverwriteEntry | Overwrite preview | One existing item on the server that a restore would replace. The Overwrite preview (IT term `OverwritePreview`) is not a class: it is the list `overwrites` of `TransferPreview` and the list `overwritten` of `TransferReport`, made of these entries. | path, size, modifiedAt | none |
| SkippedEntry | Transfer report | One entry that was not copied (a device, a socket or a pipe) and the reason. | path, reason | none |
| TransferReport | Transfer report | The account of one transfer: direction, server, times, counts of files, links and bytes, what was skipped and overwritten, the differences, whether it is verified, a note (for an incomplete transfer) and the local file it was saved to. Shown and saved; never holds a secret. | direction, configurationId, serverIdentifier, startedAt, finishedAt, fileCount, linkCount, byteCount, skipped, overwritten, differences, verified, note, reportFile | none |
| RemoteReadPort | Transfer | The boundary for what is read on a server over SSH: the host key check (`ssh-keyscan`, `ssh-keygen`), the total size, the manifest of chosen paths and the existing items under the destination of a restore. Reads only; the commands are the allow-list of [ADR-0009]. | none | checkHostKey, totalSize, manifest, existing |
| FileTransferPort | Transfer | The boundary for the two tar streams over `ssh`: `pull` unpacks the remote paths into the destination with the safe extraction filter, `push` writes the local paths to the remote destination; each returns the entries skipped. The only port that writes on a server. | none | pull, push |
| KnownHostsPort | Host key | The boundary to the one write outside a transfer: adding an accepted host key to the user's `known_hosts`. | none | trust |
| LocalFilesystemPort | Transfer | The boundary to the local files: room at a directory, whether a destination is new or empty, which paths are missing, the size and the manifests of local data, and the saving of the report file. | none | freeBytes, isNewOrEmpty, missing, size, manifestOfPaths, manifestUnder, saveReport |
| ServerAccessStore | Server access | The boundary to the saved connection facts of servers; `save` replaces the one with the same key. | none | save, load |
| AccessResolution | (result type) | What `RemoteAccessResolver` found: the outcome (READY, or SERVER_NOT_FOUND, SERVER_NOT_RUNNING, ACCESS_MISSING, HOST_KEY_UNKNOWN, HOST_KEY_CHANGED, CONNECTION_FAILED), the reason, the server, whether it is managed, the RemoteAccess and the HostKey. | outcome, reason, server, managed, access, hostKey | none |
| RemoteAccessResolver | Server access | Checks, for both transfer use cases, that the server exists at the provider and is running, that an access is recorded and an address is known, and that the host key is known; with an accepted fingerprint that equals the one shown, it has the key trusted; a changed key is never trusted. | none | resolve |
| DefineServerAccess | Server access | Realises the recording of the connection facts of [SSD-009]: checks the server exists, the user, the port, the host and the hint, and saves the ServerAccess; makes no connection. | none | defineServerAccess |
| BackUpFiles | Transfer | Realises UC-016: previews with the host key, the size and the room (the data plus a margin of 10 percent and 16 MiB must fit), and on request makes the source manifest, pulls, makes the manifest of the copy, compares and reports; changes nothing on the server. | none | previewBackup, requestBackup |
| RestoreFiles | Transfer | Realises UC-017: previews with the Overwrite preview and the confirmation required, and on a valid confirmation (the identifier typed, and again for an unmanaged server) lists again what is overwritten, makes the local manifest, pushes, makes the manifest of the copy on the server, compares and reports; writes nothing on the server before the confirmation. | none | previewRestore, requestRestore |
| TransferOutcome | Transfer | The outcomes of a preview and of a transfer: READY (preview offered), COMPLETED (copied and verified), VERIFICATION_FAILED (the manifests differ), TRANSFER_FAILED (the copy stopped), HOST_KEY_UNKNOWN, HOST_KEY_CHANGED, CONNECTION_FAILED, ACCESS_MISSING, SERVER_NOT_FOUND, SERVER_NOT_RUNNING, PATH_NOT_FOUND, INVALID_PATH, DESTINATION_NOT_EMPTY, NO_ROOM, NOT_CONFIRMED, IDENTIFIER_MISMATCH. | READY, COMPLETED, VERIFICATION_FAILED, TRANSFER_FAILED, HOST_KEY_UNKNOWN, HOST_KEY_CHANGED, CONNECTION_FAILED, ACCESS_MISSING, SERVER_NOT_FOUND, SERVER_NOT_RUNNING, PATH_NOT_FOUND, INVALID_PATH, DESTINATION_NOT_EMPTY, NO_ROOM, NOT_CONFIRMED, IDENTIFIER_MISMATCH | none |
| AccessOutcome | Server access | The outcomes of recording the connection facts: SAVED, INVALID (a user, port, host or hint that is not valid) and NOT_FOUND (no such server or configuration). | SAVED, INVALID, NOT_FOUND | none |
| ServerAccessView | Server access | Result of `defineServerAccess`: the outcome and reason, the server, the host as kept (or that the provider's address is used), the port, the user and the hint. | outcome, reason, configurationId, serverIdentifier, host, usesProviderAddress, port, user, identityHint | none |
| TransferPreview | Transfer | What a transfer will do, or why it cannot: the outcome and reason, direction, provider, configuration, server (identifier, name, state), whether it is managed, host, port, user, the host key, the paths, the destination, the size, the room free and the room required (backup), the items that would be overwritten (restore) and whether the destination exists. | outcome, reason, direction, providerName, configurationId, serverIdentifier, serverName, serverState, managed, host, port, user, hostKey, paths, destination, totalBytes, freeBytes, requiredBytes, overwrites, destinationExists | none |
| TransferResult | Transfer report | Result of a backup or a restore: the outcome, the reason, the TransferReport when one was made and the HostKey shown when it is unknown or changed. | outcome, reason, report, hostKey | none |
| ControlServerPower | Operation | Realises UC-008: checks capability, state and confirmation, sends one request and records the operation; a preview does every check but the confirmation and sends nothing; refuses the actions PROVISION, REMOVE, BACKUP and RESTORE, which have their own use cases. | none | previewPowerAction, requestPowerAction |
| TrackOperation | Operation | Realises UC-006: follows an operation to its end and records the outcome; reads the configuration to build the provider, and uses the provision port's `operationState` for an operation whose action is PROVISION, the removal port's for REMOVE and the backup port's for BACKUP and RESTORE. | none | followOperation, showOperation |
| ConfigureProviderAccess | Provider configuration | Realises UC-001: validates access and saves a configuration; keeps the validated credentials in memory until the save or the next check, and never persists them. | none | validateAccess, saveProviderConfiguration |
| DiscoverCapabilities | Capability | Realises UC-002: discovers capabilities and options. | none | discoverCapabilities, listServerOptions |
| ListServers | Server | Realises UC-007: lists and inspects servers. | none | listServers, inspectServer |
| ProxmoxProvider | (provider) | Adapter for the Proxmox VE interface: the reads, the four power requests, the container and virtual machine creations and their deletion (`DESTROY`), and the dump, the listing of archives and the restore (`ARCHIVE`). | none | implements ProviderPort, ServerPowerPort, ServerProvisionPort, ServerRemovalPort, ServerBackupPort |
| ContaboProvider | (provider) | Adapter for the Contabo interface (the reads, the four power requests, the instance creation and its cancellation, `CANCEL`, and the snapshot and its rollback, `SNAPSHOT`): exchanges the four credential values for a bearer token kept in memory, sends a request identifier on every call and renews the token once after a 401. | none | implements ProviderPort, ServerPowerPort, ServerProvisionPort, ServerRemovalPort, ServerBackupPort |
| JsonLinesConfigurationStore, JsonLinesOperationStore, JsonLinesDesiredConfigurationStore, JsonLinesProvisionIntentStore | (configuration) | Adapters that keep configuration and managed servers, operations, desired configurations and intents as JSON Lines in one file without secrets; each implements one port, because `save` and `loadAll` differ between the ports. | none | each implements its own port |
| OpenSshCommands | (provider) | Builds the argument lists of `ssh`, `ssh-keyscan` and `ssh-keygen` and the remote command templates of the allow-list of [ADR-0009]; quotes every path for a POSIX shell after `--`, sets `StrictHostKeyChecking=yes` (and `BatchMode=yes` when no terminal can answer), and puts no secret in any argument or environment variable. The three OpenSSH adapters build commands only through it. | none | none |
| OpenSshRemoteReader | Transfer | Adapter of `RemoteReadPort` that starts `ssh`, `ssh-keyscan` and `ssh-keygen` as processes: reads only. | none | implements RemoteReadPort |
| OpenSshFileTransfer | Transfer | Adapter of `FileTransferPort`: the remote `tar -cf -` read from the stdout of `ssh` and unpacked with the `data` filter of Python's `tarfile`, and the local tar stream written to the remote `tar -xf -`. | none | implements FileTransferPort |
| OpenSshKnownHosts | Host key | Adapter of `KnownHostsPort`: appends the accepted key to the user's `known_hosts` as `[host]:port` when the port is not 22. | none | implements KnownHostsPort |
| LocalDiskFilesystem | Transfer | Adapter of `LocalFilesystemPort` with `pathlib`, `shutil.disk_usage` and `hashlib`; local paths follow the operating system. | none | implements LocalFilesystemPort |
| JsonLinesServerAccessStore | Server access | Adapter of `ServerAccessStore`: keeps the `server_access` records in the one JSON Lines file, without secrets. | none | implements ServerAccessStore |
| JsonLinesBackupStore | Backup | Adapter of `BackupStore`: keeps the `backup` records in the one JSON Lines file, without secrets. | none | implements BackupStore |
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
| TrackOperation.followOperation(operationId, timeLimit, pollInterval) : OperationSummary | `followOperation` in [OC-003] and [SSD-005]; for REMOVE through `ServerRemovalPort.operationState` ([SSD-008]); for BACKUP and RESTORE through `ServerBackupPort.operationState` ([SSD-011], [SSD-012]) |
| TrackOperation.showOperation(operationId) : OperationSummary | `showOperation` in [SSD-005] |
| ServerPowerPort.requestPower(configuration, serverIdentifier, action) | `requestPowerAction` in [OC-002] |
| ServerPowerPort.operationState(configuration, operation) | `followOperation` in [OC-003] |
| OperationStore.save(operation), load(operationId) | `requestPowerAction` in [OC-002], `followOperation` in [OC-003], `requestRemoval` and `completeRemoval` in [OC-006], `requestBackup` and `completeBackup` in [OC-009], and `requestRestore` and `completeRestore` in [OC-010] |
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
| BackUpServer.previewBackup(configuration, serverIdentifier, storage) : BackupPreview | `previewBackup` in [OC-009] and [SSD-011] |
| BackUpServer.requestBackup(configuration, serverIdentifier, storage, confirmation) : BackupResult | `requestBackup` in [OC-009] and [SSD-011] |
| BackUpServer.completeBackup(operationId) : BackupResult | `completeBackup` in [OC-009] and [SSD-011] |
| ListBackups.listBackups(configuration, serverIdentifier) : BackupListing | `listBackups` in [OC-010] and [SSD-012] |
| RestoreServer.previewRestore(configuration, serverIdentifier, backupId) : RestorePreview | `previewRestore` in [OC-010] and [SSD-012] |
| RestoreServer.requestRestore(configuration, serverIdentifier, backupId, confirmation) : RestoreResult | `requestRestore` in [OC-010] and [SSD-012] |
| RestoreServer.completeRestore(operationId) : RestoreResult | `completeRestore` in [OC-010] and [SSD-012] |
| ServerBackupPort.backupKind(configuration) | `previewBackup` in [OC-009] and `previewRestore` in [OC-010] (the Backup kind stated) |
| ServerBackupPort.backupStorages(configuration, server) | `previewBackup` and `requestBackup` in [OC-009] (the storage that accepts backups) |
| ServerBackupPort.backupBlock(configuration, server, storage) | `previewBackup` and `requestBackup` in [OC-009] (the storage and unavailable-server exceptions) |
| ServerBackupPort.restoreBlock(configuration, server, backup) | `previewRestore` and `requestRestore` in [OC-010] (the running, unavailable and mismatch exceptions) |
| ServerBackupPort.backupConsequence(configuration, server, storage) | `previewBackup` in [OC-009] (the Consequence text) and `requestBackup` (recorded with the Operation) |
| ServerBackupPort.restoreEffect(configuration, server, backup) | `previewRestore` in [OC-010] (the Restore effect and the backups deleted) and `requestRestore` (the Consequence recorded) |
| ServerBackupPort.requestBackup(configuration, server, storage) | `requestBackup` in [OC-009] (the one backup request) |
| ServerBackupPort.requestRestore(configuration, server, backup) | `requestRestore` in [OC-010] (the one restore request) |
| ServerBackupPort.listBackups(configuration, server) | `listBackups`, `previewRestore` and `requestRestore` in [OC-010] (the Backups the provider reports) |
| ServerBackupPort.findBackup(configuration, operation) | `completeBackup` in [OC-009] (the Backup located) |
| ServerBackupPort.operationState(configuration, operation) | `followOperation` in [OC-003] for an operation with action BACKUP or RESTORE; `completeRestore` in [OC-010] reads the state of the Server through `ProviderPort.getServer` |
| BackupStore.save(record) | `completeBackup` in [OC-009] (the Backup recorded) |
| BackupStore.load(configurationId, serverIdentifier, backupId), loadFor(configurationId, serverIdentifier) | `listBackups` in [OC-010] (the Operation that made each Backup; the recorded Backups the provider no longer lists) |
| BackupStore.loadByOperation(operationId) | `completeBackup` in [OC-009] (completing again records no second Backup) |
| Backup.alias() | `listBackups` and `previewRestore` in [OC-010] (the short alias; the alias accepted as `backupId`) |
| ProviderResolver.backupFor(configuration) | Supporting operation of `previewBackup`, `requestBackup`, `completeBackup`, `listBackups`, `previewRestore`, `requestRestore` and `completeRestore` (credentials differ per configuration) |
| ProviderResolver.removalFor(configuration) | Supporting operation of `previewRemoval`, `requestRemoval` and `completeRemoval` (credentials differ per configuration) |
| ConfigurationStore.saveManagedServer(record) | `completeProvisioning` in [OC-005] (the ManagedServerRecord) |
| ConfigurationStore.endManagedServer(configurationId, serverIdentifier, endedAt, operationId) | `completeRemoval` in [OC-006] (the Managed server ended) |
| ProviderResolver.provisionFor(configuration) | Supporting operation of `defineDesiredConfiguration`, `validateDesiredConfiguration`, `previewProvisioning`, `requestProvisioning` and `completeProvisioning` (credentials differ per configuration) |
| ProviderResolver.providerFor(configuration) | Supporting operation of `discoverCapabilities`, `listServerOptions`, `listServers`, `inspectServer`, `previewRemoval`, `requestRemoval`, `previewBackup`, `requestBackup`, `listBackups`, `previewRestore` and `requestRestore` (credentials differ per configuration) |
| ProviderPort.validateAccess(address, credentials) | `validateAccess` in [SSD-001] |
| ProviderPort.discoverCapabilities(configuration) | `discoverCapabilities` in [SSD-002] |
| ProviderPort.listServerOptions(configuration, optionKind) | `listServerOptions` in [SSD-002] |
| ProviderPort.listServers(configuration) | `listServers` in [SSD-003] |
| ProviderPort.getServer(configuration, serverIdentifier) | `inspectServer` in [SSD-003]; `previewRemoval` and `requestRemoval` in [OC-006] (the server read first); `previewBackup`, `requestBackup` in [OC-009], `previewRestore`, `requestRestore` and `completeRestore` in [OC-010] (the server read first, and its state afterwards) |
| ConfigurationStore.save(configuration) | `saveProviderConfiguration` in [OC-001] |
| ConfigurationStore.loadAll(), managedServers(configurationId) | `listServers` in [SSD-003] (managed marking), `previewRemoval` and `requestRemoval` in [OC-006] and `previewRestore` and `requestRestore` in [OC-010] (managed or not) and the configuration lookup of every message |
| CredentialStore.put(reference, credentials) | `saveProviderConfiguration` in [OC-001] (cacheCredential) |
| CredentialStore.get(reference) | `validateAccess` in [SSD-001] and `discoverCapabilities` in [SSD-002] (stored credentials) |
| CredentialPrompt.ask(providerKind) | `validateAccess` in [SSD-001] (credentials parameter) |
| DefineServerAccess.defineServerAccess(configuration, serverIdentifier, host, port, user, identityHint) : ServerAccessView | `defineServerAccess` in [OC-007] and [SSD-009] |
| BackUpFiles.previewBackup(configuration, serverIdentifier, remotePaths, destination, acceptedFingerprint) : TransferPreview | `previewBackup` in [OC-007] and [SSD-009] |
| BackUpFiles.requestBackup(configuration, serverIdentifier, remotePaths, destination) : TransferResult | `requestBackup` in [OC-007] and [SSD-009] |
| RestoreFiles.previewRestore(configuration, serverIdentifier, localPaths, remoteDestination, acceptedFingerprint) : TransferPreview | `previewRestore` in [OC-008] and [SSD-010] |
| RestoreFiles.requestRestore(configuration, serverIdentifier, localPaths, remoteDestination, reportDirectory, confirmation) : TransferResult | `requestRestore` in [OC-008] and [SSD-010] |
| RemoteAccessResolver.resolve(configuration, serverIdentifier, acceptedFingerprint) : AccessResolution | Supporting operation: the preconditions on the Server, its state, the Server access, the address and the Host key of `previewBackup` and `requestBackup` in [OC-007] and of `previewRestore` and `requestRestore` in [OC-008] |
| RemoteReadPort.checkHostKey(access) | `previewBackup` in [OC-007] and `previewRestore` in [OC-008] (the Host key precondition), repeated in `requestBackup` and `requestRestore` |
| RemoteReadPort.totalSize(access, paths) | `previewBackup` in [OC-007] (the size to copy) and `requestBackup` (the room check) |
| RemoteReadPort.manifest(access, root, relativePaths) | `requestBackup` in [OC-007] (the Manifest at the Server before the copy) and `requestRestore` in [OC-008] (the Manifest of the copy on the Server) |
| RemoteReadPort.existing(access, root, names) | `previewRestore` and `requestRestore` in [OC-008] (the Overwrite preview) |
| FileTransferPort.pull(access, remotePaths, destination) | `requestBackup` in [OC-007] (the copy to the destination) |
| FileTransferPort.push(access, localPaths, remoteDestination) | `requestRestore` in [OC-008] (the copy to the Server, after the confirmation) |
| KnownHostsPort.trust(hostKey) | `previewBackup` in [OC-007] and `previewRestore` in [OC-008] (the accepted fingerprint of an unknown Host key) |
| LocalFilesystemPort.freeBytes(directory), isNewOrEmpty(directory) | `previewBackup` in [OC-007] (the room and the destination preconditions) |
| LocalFilesystemPort.missing(paths), size(paths) | `previewRestore` in [OC-008] (the local paths exist; the size to copy) |
| LocalFilesystemPort.manifestOfPaths(paths) | `requestRestore` in [OC-008] (the Manifest of the local data before the copy) |
| LocalFilesystemPort.manifestUnder(directory, relativePaths) | `requestBackup` in [OC-007] (the Manifest of the copy at the destination) |
| LocalFilesystemPort.saveReport(directory, report) | `requestBackup` in [OC-007] and `requestRestore` in [OC-008] (the Transfer report saved as a file) |
| ServerAccessStore.save(access) | `defineServerAccess` in [OC-007] |
| ServerAccessStore.load(configurationId, serverIdentifier) | `previewBackup` in [OC-007] and `previewRestore` in [OC-008] (the Server access precondition), through `RemoteAccessResolver.resolve` |

## Pattern Annotations

| Pattern | Classes | Rationale |
| --- | --- | --- |
| Ports and adapters | ProviderPort, ConfigurationStore, CredentialStore, CredentialPrompt and their adapters | Keeps the application free of provider, file and platform detail; a second provider is a new adapter ([ADR-0002]). |
| Composition root | CliApplication | The only place that names infrastructure classes. |
| Strategy | ProviderPort, ProxmoxProvider, ContaboProvider | Provider differences sit behind one interface; use cases do not test the provider kind ([ADR-0002]). |
| Interface segregation | ProviderPort, ServerPowerPort, ServerProvisionPort, ServerRemovalPort, ServerBackupPort | Read-only code cannot reach a write by type; the write surface is the four power requests ([ADR-0006]), the create requests ([ADR-0007]), the two removal requests ([ADR-0008]) and the backup and restore requests ([ADR-0010]). |
| Strategy | BackupKind, ServerBackupPort | The two ways to keep a backup, an archive and a snapshot, sit behind one port; the use cases ask the port what a restore deletes and what blocks it and do not test the provider kind ([ADR-0002], [ADR-0010]). |
| Fake | ServerBackupPort, BackupStore | An in-process implementation of the port and the store runs the backup contract suite and the unit tests without a network ([ADR-0001], [ADR-0010]). |
| Write-ahead record | ProvisionIntent, ProvisionIntentStore, ProvisionServer | The intent is saved before the create request, so a lost answer leaves a pending intent that a retry meets ([ADR-0007]). |
| Data-driven validation | ValueRule, DesiredConfigurationValidator | Each provider declares its values as data; the validator holds one rule for every provider and use cases do not test the provider kind ([ADR-0002]). |
| Resolver | ProviderResolver, CliProviderResolver | The adapter takes its credentials at construction, and one run spans several configurations, so a port instance per configuration is resolved on demand. |
| Capability set | Capability, ProviderPort.discoverCapabilities | Provider differences are declared, not hidden ([ADR-0002]). |
| Interface segregation | RemoteReadPort, FileTransferPort, KnownHostsPort, LocalFilesystemPort | Reads on a server, the streams that write, the one write to `known_hosts` and the local files are four ports; the remote reads cannot write by type, and the remote write surface is `FileTransferPort.push` alone, which `BackUpFiles` never calls ([ADR-0009]). |
| Allow-list | OpenSshCommands | Every command that runs on a server comes from a fixed template in one class, so a test can list them ([ADR-0009]). |
| Fake | RemoteReadPort, FileTransferPort, KnownHostsPort, LocalFilesystemPort | An in-process implementation of each port runs the transfer contract suite and the unit tests without a network ([ADR-0001], [ADR-0009]). |
| Single place for shared rules | RemoteAccessResolver | The server, access and host key checks of backup and restore are written once. |

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
[UC-016]: ./use-cases/uc-016/uc.md
[UC-017]: ./use-cases/uc-017/uc.md
[SSD-008]: ./use-cases/uc-012/ssd.md
[OC-006]: ./use-cases/uc-012/oc.md
[ADR-0009]: ./adr/adr-0009-server-access-and-file-transfer.md
[SSD-009]: ./use-cases/uc-016/ssd.md
[OC-007]: ./use-cases/uc-016/oc.md
[SSD-010]: ./use-cases/uc-017/ssd.md
[OC-008]: ./use-cases/uc-017/oc.md
[ADR-0001]: ./adr/adr-0001-provider-test-strategy.md
[ADR-0010]: ./adr/adr-0010-whole-server-backup-and-restore.md
[UC-018]: ./use-cases/uc-018/uc.md
[UC-019]: ./use-cases/uc-019/uc.md
[SSD-011]: ./use-cases/uc-018/ssd.md
[OC-009]: ./use-cases/uc-018/oc.md
[SSD-012]: ./use-cases/uc-019/ssd.md
[OC-010]: ./use-cases/uc-019/oc.md
[9fd15f2]: https://git.tirsystem.com/TirSystem/iac-node-forge/commit/9fd15f248c031b5899ed480055d33b09a2ea62fa
