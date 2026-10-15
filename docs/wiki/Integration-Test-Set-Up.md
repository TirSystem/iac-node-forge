**English**

# 1. Set up the container

Part 1 of 3 of the [real Proxmox VE integration test](Integration-Test). When this part
is done, a Proxmox VE answers on `https://localhost:8006` and you hold an API token for
it.

Every command is given twice: **Linux and macOS (bash)** and **Windows (PowerShell 7)**.
Use the one for your shell. Run them in the `iac-node-forge-py` folder.

## 1.1 Choose the image

The compose file `tests/integration/docker-compose.proxmox.yml` names the image. The name
it was first written with (`maconrad/proxmox`) does not exist on Docker Hub, so set the
`image:` line to the image you decided to use before you start the container.

Check the image's page and its source on Docker Hub first. It is a community image, not
Proxmox's own, and it runs privileged.

## 1.2 Put the password in `pve.env`

The password comes from the file `tests/integration/pve.env`. The file is ignored by git;
never commit it.

**Linux and macOS (bash)**

```bash
cp tests/integration/pve.env.example tests/integration/pve.env
${EDITOR:-nano} tests/integration/pve.env      # set PVE_PASSWORD=<choose a password>
chmod 600 tests/integration/pve.env
```

**Windows (PowerShell)**

```powershell
Copy-Item tests/integration/pve.env.example tests/integration/pve.env
notepad tests/integration/pve.env      # set PVE_PASSWORD=<choose a password>
```

The file has one `KEY=value` per line and no spaces around the equals sign. A dollar sign
in the value must be written twice (`$$`), because compose expands variables.

## 1.3 Start the container

**Linux and macOS (bash)**

```bash
docker compose --env-file tests/integration/pve.env \
  -f tests/integration/docker-compose.proxmox.yml up -d
```

**Windows (PowerShell)**

```powershell
docker compose --env-file tests/integration/pve.env -f tests/integration/docker-compose.proxmox.yml up -d
```

The compose file has no default password: it stops with an error if `PVE_PASSWORD` is
missing from the file.

## 1.4 Wait for the web interface

It can take a minute or two. The certificate is self-signed, so the check skips the
certificate test.

**Linux and macOS (bash)**

```bash
curl -k -s -o /dev/null -w '%{http_code}\n' https://localhost:8006
```

**Windows (PowerShell 7)**

```powershell
Invoke-WebRequest -SkipCertificateCheck https://localhost:8006 | Select-Object StatusCode
```

`200` means it is up. If it never answers, look at the log (same command in both shells):

```bash
docker logs proxmox-node1 --tail 60
```

## 1.5 Set the root password

Some images ignore `PVE_PASSWORD`. Set it from the value the container itself received, so
it never appears on a command line and your shell does not have to read the file. The
command is the same in both shells:

```bash
docker exec proxmox-node1 sh -c 'echo "root:$PVE_PASSWORD" | chpasswd'
```

The single quotes matter: the `$` is expanded inside the container, not by your shell.

No output means success. You can check it in a browser at `https://localhost:8006`: user
`root`, realm `Linux PAM standard authentication`, and your password.

## 1.6 Create the API token

The token is what the tests use. These commands keep it off the screen and out of files.

**Linux and macOS (bash)**

```bash
out="$(docker exec proxmox-node1 pveum user token add root@pam iacnf --privsep 0 --output-format json)"
export PVE_TOKEN="$(printf '%s' "$out" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["full-tokenid"] + "=" + d["value"])')"
export PVE_VERIFY=false
unset out
```

**Windows (PowerShell)**

```powershell
$out = docker exec proxmox-node1 pveum user token add root@pam iacnf --privsep 0 --output-format json | ConvertFrom-Json
$env:PVE_TOKEN = "$($out.'full-tokenid')=$($out.value)"
$env:PVE_VERIFY = 'false'
Remove-Variable out
```

`PVE_VERIFY=false` is needed because the container has a self-signed certificate.

If `--output-format json` is not accepted, run the `docker exec` command without it. It
prints a table; the row `value` is the secret. Then set the variable by hand:

```bash
export PVE_TOKEN='root@pam!iacnf=<value from the table>'        # bash
```

```powershell
$env:PVE_TOKEN = 'root@pam!iacnf=<value from the table>'         # PowerShell
```

## Problems

| Message or symptom | Cause and fix |
| --- | --- |
| `pull access denied ... repository does not exist` | The image name in the compose file is wrong. See 1.1. |
| Mount error for `/lib/modules` | Docker Desktop for Windows or macOS has no such host path. Remove that one `volumes:` entry from your local copy and retry; tell the maintainer if the image then fails to start. |
| `set PVE_PASSWORD in your environment` | `PVE_PASSWORD` is missing from `pve.env`, or `--env-file` was left out. Repeat 1.2 and 1.3. |
| Login rejected in the browser | The image did not use `PVE_PASSWORD`. Repeat 1.5. |
| `chpasswd: command not found` | The image is not Debian based; this guide does not cover it. |
| The container cannot start on Linux | It needs `privileged` and the host's `/lib/modules`; check that Docker runs as root or the user is in the `docker` group. |

Next: [2. Run the tests](Integration-Test-Run).
