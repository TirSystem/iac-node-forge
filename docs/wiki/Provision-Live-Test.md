**English**

# Provisioning and removal live test

> **This test creates a container and then removes it, in the throw-away Proxmox VE of the
> integration tests.** Run it only against that Docker Proxmox VE, never against a Proxmox VE
> you use for real work. The removal is the product's own (`RemoveServer`, the same as
> `server remove`), and it touches only the container the test created, whose name starts with
> `iacnf-live-`. A Contabo instance is **never** created or cancelled by a test, because it costs
> money and commits the account to a contract period.

The live test acts through the same use cases and adapters as the command line:
`DefineDesiredConfiguration`, `ProvisionServer`, `RemoveServer` and `TrackOperation` with the real
Proxmox VE adapter. It is marked `integration`, is skipped unless **everything** below is set, and never
runs in CI.

## What the scenario does

1. Define a small desired configuration (a Linux container: 128 MB, 1 core, 1 GB disk) and
   validate it against what the Proxmox VE offers.
2. Preview the provisioning and check that nothing was sent.
3. Confirm, follow the operation to its end and complete it: expect `succeeded`, a server
   recorded as managed and the container listed under the chosen name.
4. Ask for the same name again and expect a refusal with **no request**.
5. Remove it through the product: the preview states that the server and its disks are destroyed
   now; a wrong typed identifier and a missing confirmation send **nothing**; the confirmed request
   is followed to its end and completed; the consequence is recorded with the operation, the
   managed record is ended and the container is no longer listed; a second request reports "not
   found" with no request.
6. A finalizer removes the container through the product if the test failed before step 5. If
   the container is running, the test fails and names it; remove it by hand in that case.

## 1. Start the Docker Proxmox VE

Run these in the `iac-node-forge-py` folder. The Docker Proxmox VE needs `/dev/kvm`; if the
container stops at once with "KVM acceleration is not available", see
[Set up the container](Integration-Test-Set-Up).

Copy `tests/integration/pve.env.example` to `tests/integration/pve.env` (git-ignored) and set a
password in it, then:

**Linux and macOS (bash)**

```bash
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml up -d
set -a; . tests/integration/pve.env; set +a
printf 'root:%s\n' "$PVE_PASSWORD" | docker exec -i proxmox-node1 chpasswd
```

**Windows (PowerShell)**

```powershell
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml up -d
Get-Content tests/integration/pve.env | Where-Object { $_ -and $_ -notmatch '^\s*#' } | ForEach-Object {
    $name, $value = $_ -split '=', 2
    [Environment]::SetEnvironmentVariable($name.Trim(), $value.Trim(), 'Process')
}
"root:$env:PVE_PASSWORD" | docker exec -i proxmox-node1 chpasswd
```

Wait until the web interface answers (a minute or two), then create the API token and download
a container template. The token is kept in the session and never written to a file:

**Linux and macOS (bash)**

```bash
out=$(docker exec proxmox-node1 pveum user token add root@pam iacnf --privsep 0 --output-format json)
export PVE_TOKEN="$(printf '%s' "$out" | python -c "import sys,json;d=json.load(sys.stdin);print(d['full-tokenid']+'='+d['value'])")"
export PVE_VERIFY=false
docker exec proxmox-node1 pveam update
docker exec proxmox-node1 pveam available --section system
```

**Windows (PowerShell)**

```powershell
$out = docker exec proxmox-node1 pveum user token add root@pam iacnf --privsep 0 --output-format json | ConvertFrom-Json
$env:PVE_TOKEN = "$($out.'full-tokenid')=$($out.value)"
$env:PVE_VERIFY = 'false'
docker exec proxmox-node1 pveam update
docker exec proxmox-node1 pveam available --section system
```

Pick an Alpine template from the list and download it (the name changes over time):

```bash
docker exec proxmox-node1 pveam download local alpine-3.24-default_20260714_amd64.tar.xz
```

## 2. Set the variables

The token and `PVE_VERIFY` above, and then the four provisioning variables. The node name is
what `docker exec proxmox-node1 pvesh get /nodes --output-format json` shows. The template is
the volume id of the file you downloaded, `local:vztmpl/<file>`.

**Linux and macOS (bash)**

```bash
export PVE_PROVISION_TEST_NODE=<node>
export PVE_PROVISION_TEST_STORAGE=local
export PVE_PROVISION_TEST_TEMPLATE=<template as listed>
export PVE_PROVISION_TEST_CONFIRM=create-server-iacnf-live
```

**Windows (PowerShell)**

```powershell
$env:PVE_PROVISION_TEST_NODE     = '<node>'
$env:PVE_PROVISION_TEST_STORAGE  = 'local'
$env:PVE_PROVISION_TEST_TEMPLATE = '<template as listed>'
$env:PVE_PROVISION_TEST_CONFIRM  = 'create-server-iacnf-live'
```

The confirmation text must be exactly `create-server-iacnf-live`. This is deliberate: it names
what will be created, and a test with another value is skipped.

## 3. Run

The same command in both shells:

```bash
pytest -m integration -k provision -v -rs
```

| Result | Meaning |
| --- | --- |
| passed | A container was created, recorded as managed, removed through the product, and the record ended. |
| skipped, a list of variable names | Those variables are not set in this session. |
| skipped, "confirmation text does not match" | The confirm variable is wrong; nothing was touched. |
| a failure in a step | Look in the Proxmox VE web interface (`https://localhost:8006`) for a container named `iacnf-live-...`; the finalizer will have tried to remove it. |

Report the summary lines and the names of failing tests. Never send a token or a password.

## 4. Take it down

Remove the token and the variables, then stop and delete the Docker container:

**Linux and macOS (bash)**

```bash
unset PVE_TOKEN PVE_VERIFY PVE_PASSWORD PVE_PROVISION_TEST_NODE PVE_PROVISION_TEST_STORAGE PVE_PROVISION_TEST_TEMPLATE PVE_PROVISION_TEST_CONFIRM
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml down
```

**Windows (PowerShell)**

```powershell
Remove-Item Env:PVE_TOKEN, Env:PVE_VERIFY, Env:PVE_PASSWORD, Env:PVE_PROVISION_TEST_NODE, Env:PVE_PROVISION_TEST_STORAGE, Env:PVE_PROVISION_TEST_TEMPLATE, Env:PVE_PROVISION_TEST_CONFIRM -ErrorAction SilentlyContinue
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml down
```
