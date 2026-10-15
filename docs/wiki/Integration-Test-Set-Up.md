**English**

# 1. Set up the container

Part 1 of 3 of the [real Proxmox VE integration test](Integration-Test). When this part
is done, a Proxmox VE answers on `https://localhost:8006` and you hold an API token for
it.

## 1.1 Choose the image

The compose file `tests/integration/docker-compose.proxmox.yml` names the image. The name
it was first written with (`maconrad/proxmox`) does not exist on Docker Hub, so set the
`image:` line to the image you decided to use before you start the container.

Check the image's page and its source on Docker Hub first. It is a community image, not
Proxmox's own, and it runs privileged.

## 1.2 Start the container

Run these in PowerShell, in the `iac-node-forge-py` folder:

```powershell
# the password stays in this session only; choose a new one
$env:PVE_PASSWORD = '<choose a password>'

docker compose -f tests/integration/docker-compose.proxmox.yml up -d
```

The compose file has no default password: it stops with an error if `PVE_PASSWORD` is not
set.

## 1.3 Wait for the web interface

It can take a minute or two. In PowerShell 7:

```powershell
Invoke-WebRequest -SkipCertificateCheck https://localhost:8006 | Select-Object StatusCode
```

`200` means it is up. If it never answers, look at the log:

```powershell
docker logs proxmox-node1 --tail 60
```

## 1.4 Set the root password

Some images ignore `PVE_PASSWORD`. Set it from the variable, through standard input, so it
never appears on a command line:

```powershell
"root:$env:PVE_PASSWORD" | docker exec -i proxmox-node1 chpasswd
```

No output means success. You can check it in a browser at `https://localhost:8006`: user
`root`, realm `Linux PAM standard authentication`, and your password.

## 1.5 Create the API token

The token is what the tests use. This keeps it out of the screen and out of files:

```powershell
$out = docker exec proxmox-node1 pveum user token add root@pam iacnf --privsep 0 --output-format json | ConvertFrom-Json
$env:PVE_TOKEN = "$($out.'full-tokenid')=$($out.value)"
$env:PVE_VERIFY = 'false'
```

`PVE_VERIFY = 'false'` is needed because the container has a self-signed certificate.

If `--output-format json` is not accepted, run the command without it. It prints a table;
the row `value` is the secret. Then set the variable by hand:

```powershell
$env:PVE_TOKEN = 'root@pam!iacnf=<value from the table>'
```

## Problems

| Message or symptom | Cause and fix |
| --- | --- |
| `pull access denied ... repository does not exist` | The image name in the compose file is wrong. See 1.1. |
| Mount error for `/lib/modules` | Docker Desktop for Windows has no such host path. Remove that one `volumes:` entry from your local copy and retry; tell the maintainer if the image then fails to start. |
| `set PVE_PASSWORD in your environment` | The variable is not set in this PowerShell session. Repeat 1.2. |
| Login rejected in the browser | The image did not use `PVE_PASSWORD`. Repeat 1.4. |
| `chpasswd: command not found` | The image is not Debian based; this guide does not cover it. |

Next: [2. Run the tests](Integration-Test-Run).
