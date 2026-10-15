**English**

# 3. Take it down

Part 3 of 3 of the [real Proxmox VE integration test](Integration-Test). Do this when you
have your result. Commands are given for **Linux and macOS (bash)** and **Windows
(PowerShell)**; run them in the `iac-node-forge-py` folder.

## 3.1 Stop and remove the container

**Linux and macOS (bash)**

```bash
docker compose --env-file tests/integration/pve.env \
  -f tests/integration/docker-compose.proxmox.yml down
```

**Windows (PowerShell)**

```powershell
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml down
```

Add `--volumes` if the compose file ever gets a named volume and you want its data gone
too. The current file has none, so everything inside the container is removed with it.

## 3.2 Remove the secrets

`pve.env` holds the password; delete it when you no longer need the container. The token
only ever lived in the variable of your session.

**Linux and macOS (bash)**

```bash
rm -f tests/integration/pve.env
unset PVE_TOKEN PVE_VERIFY PVE_ADDRESS PVE_PASSWORD
```

**Windows (PowerShell)**

```powershell
Remove-Item tests/integration/pve.env -ErrorAction SilentlyContinue
Remove-Item Env:PVE_TOKEN, Env:PVE_VERIFY, Env:PVE_ADDRESS, Env:PVE_PASSWORD -ErrorAction SilentlyContinue
```

Closing the terminal clears the variables too.

## 3.3 Optional: remove the image

The same commands in both shells:

```bash
docker image ls
docker image rm <image name>
```

## 3.4 Leave the virtual environment

The same command in both shells:

```bash
deactivate
```

## Check that nothing is left

**Linux and macOS (bash)**

```bash
docker ps -a --filter "name=proxmox-node1"
git status --short
ls tests/integration/pve.env 2>/dev/null || echo "pve.env removed"
```

**Windows (PowerShell)**

```powershell
docker ps -a --filter "name=proxmox-node1"
git status --short
Test-Path tests/integration/pve.env        # False
```

The first command should list no container. `git status` should show no change you did
not expect; in particular, no token or password in any file.

Back to the [overview](Integration-Test).
