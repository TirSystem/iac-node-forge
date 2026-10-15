**English**

# 3. Take it down

Part 3 of 3 of the [real Proxmox VE integration test](Integration-Test). Do this when you
have your result.

## 3.1 Stop and remove the container

In the `iac-node-forge-py` folder:

```powershell
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml down
```

Add `--volumes` if the compose file ever gets a named volume and you want its data gone
too. The current file has none, so everything inside the container is removed with it.

## 3.2 Remove the secrets

```powershell
Remove-Item tests/integration/pve.env
Remove-Item Env:PVE_TOKEN, Env:PVE_VERIFY -ErrorAction SilentlyContinue
```

`pve.env` holds the password; delete it when you no longer need the container. The token
only ever lived in the variable of your session, and closing the PowerShell window clears
it too.

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
