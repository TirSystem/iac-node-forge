**English**

# Whole-server backup and restore live test

> **This test backs up a container, changes it, restores it over itself and then removes it, in
> the throw-away Proxmox VE of the integration tests.** Run it only against that Docker Proxmox
> VE, never against a Proxmox VE you use for real work. A restore **overwrites** the guest and
> cannot be undone. A Contabo snapshot is **never** created or rolled back by a test, because a
> snapshot costs money and a rollback deletes every newer snapshot.

The live test acts through the same use cases and adapters as the command line: `ProvisionServer`,
`BackUpServer`, `ListBackups`, `RestoreServer`, `RemoveServer` and `TrackOperation` with the real
Proxmox VE adapter. It is marked `integration`, is skipped unless **everything** below is set, and
never runs in CI.

## What the scenario does

1. Create a small container through the product (as in the
   [provisioning and removal test](Provision-Live-Test)).
2. Back it up: the preview names the backup storage and sends nothing; a request without the
   confirmation sends nothing; the confirmed request is followed to its end, the archive is found
   again by listing the storage, and the backup is recorded and shown by `ListBackups`.
3. **Change the container** so that a restore can be seen: one documented test-only write sets its
   description, and the test reads it back. This is the only write that does not go through the
   product, besides deleting the archive at the end.
4. Restore it through the product: the preview says that the guest, its disks and its
   configuration are overwritten and that this cannot be undone; a wrong typed identifier and a
   missing confirmation send **nothing**; the confirmed request is followed and completed, the
   state of the server is reported, the consequence is recorded with the operation, and the
   description is back to what it was.
5. Remove the container through the product. A finalizer does this, and deletes the archive this
   run made, even when a step fails.

An optional **experiment** records what Proxmox VE does when a restore is tried over a *running*
container. The product refuses that case before it sends anything; the experiment sends it
directly, only to learn the answer.

## 1. Start the Docker Proxmox VE and set the variables

Follow steps 1 and 2 of the [provisioning and removal guide](Provision-Live-Test): start the
container with `docker compose`, set the root password, create the API token, download the
Alpine template, and set `PVE_TOKEN`, `PVE_VERIFY` and the four `PVE_PROVISION_TEST_` variables.
The default storage `local` of the Docker Proxmox VE accepts backups. Two optional variables:

**Linux and macOS (bash)**

```bash
export PVE_PROVISION_TEST_BACKUP_STORAGE=local   # only needed if more than one storage takes backups
export PVE_PROVISION_TEST_EXPERIMENT=1           # also try a restore over a running container
```

**Windows (PowerShell)**

```powershell
$env:PVE_PROVISION_TEST_BACKUP_STORAGE = 'local'
$env:PVE_PROVISION_TEST_EXPERIMENT     = '1'
```

## 2. Run

The same command in both shells:

```bash
pytest -m integration -k full_backup -v -s
```

| Result | Meaning |
| --- | --- |
| passed | A container was backed up, changed, restored, and removed again; no leftover container or archive. |
| skipped, a list of variable names | Those variables are not set in this session. |
| failed with "enable backup content" | No storage of the node accepts backups; enable the content type `backup` on a storage. |
| a failure in a step | Look in the Proxmox VE web interface (`https://localhost:8006`) for a container named `iacnf-live-...` and for its archive; the finalizer will have tried to remove both. |

With the experiment, the lines starting `EXPERIMENT NOTE:` show what Proxmox VE answered; report
them. A run takes about 20 minutes because the Docker Proxmox VE runs under emulation.

## 3. Take it down

As in [step 4 of the provisioning guide](Provision-Live-Test): unset the variables, remove the
token and stop and delete the Docker container.

**Linux and macOS (bash)**

```bash
unset PVE_PROVISION_TEST_BACKUP_STORAGE PVE_PROVISION_TEST_EXPERIMENT
```

**Windows (PowerShell)**

```powershell
Remove-Item Env:PVE_PROVISION_TEST_BACKUP_STORAGE, Env:PVE_PROVISION_TEST_EXPERIMENT -ErrorAction SilentlyContinue
```

## Using the commands on a real server

```bash
iac-node-forge server full-backup  <configuration> <server> [--storage <storage>]
iac-node-forge server full-backups <configuration> <server>
iac-node-forge server full-restore <configuration> <server> <backup>
```

At Proxmox VE a backup is an archive in a backup storage and a restore overwrites the same guest;
the guest must be stopped first. At Contabo a backup is a snapshot and a restore is a rollback
that deletes every newer snapshot. Neither provider lets the product copy a backup to your PC.
