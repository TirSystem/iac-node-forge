**English**

# 3. Take it down

Part 3 of 3 of the [real Proxmox VE integration test](Integration-Test). Do this when you
have your result.

## 3.1 Stop and remove the container

In the `iac-node-forge-py` folder:

```powershell
docker compose -f tests/integration/docker-compose.proxmox.yml down
```

Add `--volumes` if the compose file ever gets a named volume and you want its data gone
too. The current file has none, so everything inside the container is removed with it.

## 3.2 Clear the secrets from your session

```powershell
Remove-Item Env:PVE_TOKEN, Env:PVE_PASSWORD, Env:PVE_VERIFY -ErrorAction SilentlyContinue
```

Closing the PowerShell window does the same. Nothing was written to a file.

## 3.3 Optional: remove the image

```powershell
docker image ls
docker image rm <image name>
```

## 3.4 Leave the virtual environment

```powershell
deactivate
```

## Check that nothing is left

```powershell
docker ps -a --filter "name=proxmox-node1"
git status --short
```

The first command should list nothing. The second should show no change you did not
expect; in particular, no token or password in any file.

Back to the [overview](Integration-Test).
