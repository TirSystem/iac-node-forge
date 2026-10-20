**English**

# File backup and restore live test

> **This test starts a throw-away SSH server in a Docker container on your own machine and copies
> files to and from it.** It never connects to a real server, and it never reads or changes your own
> `~/.ssh` (your keys, your `known_hosts` and your `ssh_config`). It uses a new key pair that exists
> only for the run, and a temporary `known_hosts`. The container is removed when the run ends.

The tests act through the same use cases and adapters as the command line: `server access`,
`server backup` and `server restore` with the real OpenSSH adapters and the real local disk. They are
marked `integration`, are skipped unless `IACNF_SSHD_TEST` is `1`, and never run in CI. Docker needs
no `/dev/kvm` for this test.

## What the tests do

1. **The contract suite** (`tests/contract/test_transfer_contract.py`) runs every transfer behaviour
   against an in-process fake and against the real OpenSSH adapters and a real `sshd`: copying a tree
   both ways, a changed byte, a missing path, links, an unknown host key, a changed host key, and a
   backup that changes nothing on the server.
2. **The round trip** (`tests/integration/test_transfer_live.py`) runs the real commands:
   - an **unknown host key** stops the backup and prints its fingerprint, with nothing copied;
   - the backup with `--accept-host-key <that fingerprint>` copies and verifies, the local tree equals
     the server's tree and the server is unchanged;
   - after a change on the server, `server restore` lists what it would replace, writes **nothing**
     without the typed confirmation, and then copies and verifies; files that were already on the
     server and are not in the backup are left in place and reported;
   - a **changed host key** stops the backup and is never accepted, not even with `--accept-host-key`;
   - no key, password or passphrase appears in any output, record or report.

## 1. What you need

- Docker (Docker Desktop on Windows works).
- The OpenSSH client tools `ssh`, `ssh-keygen` and `ssh-keyscan` (they come with Windows 10 and later,
  and with Git for Windows).

The container `iacnf-sshd` is built from the public image `alpine` with `openssh-server`, listens on
`127.0.0.1:2222` only, and lets the user `tester` in with the throw-away key only (no password).

## 2. Run

Run these in the `iac-node-forge-py` folder, in the session with your virtual environment.

**Linux and macOS (bash)**

```bash
export IACNF_SSHD_TEST=1
pytest -m integration tests/contract/test_transfer_contract.py -v
pytest -m integration -k transfer_live -v
```

**Windows (PowerShell)**

```powershell
$env:IACNF_SSHD_TEST = '1'
pytest -m integration tests/contract/test_transfer_contract.py -v
pytest -m integration -k transfer_live -v
```

| Result | Meaning |
| --- | --- |
| passed | The copies were made and verified, and the container is gone. |
| skipped, a reason | `IACNF_SSHD_TEST` is not `1`, or Docker or the OpenSSH tools are missing. |
| a failure in a step | Run `docker ps -a` and remove a leftover container named `iacnf-sshd` by hand. |

The first run builds the image and takes a minute or two; later runs take under a minute.

## 3. Clean up

**Linux and macOS (bash)**

```bash
unset IACNF_SSHD_TEST
docker rm -f iacnf-sshd 2>/dev/null
```

**Windows (PowerShell)**

```powershell
Remove-Item Env:IACNF_SSHD_TEST -ErrorAction SilentlyContinue
docker rm -f iacnf-sshd 2>$null
```

## Using the commands on a real server

The commands need the server's SSH connection facts once, kept without any secret:

```bash
iac-node-forge server access <configuration> <server> --user <user> [--host <address>] [--port 22] [--identity <key file or agent name>]
iac-node-forge server backup <configuration> <server> <remote-path>... --to <local-folder>
iac-node-forge server restore <configuration> <server> <local-path>... --to <remote-folder>
```

Your own SSH agent, key files and `known_hosts` are used. The first backup of a server stops at its
host key and prints the fingerprint; compare it with the one you trust and repeat the command with
`--accept-host-key <fingerprint>`. A restore **overwrites** files on the server, does not keep the
previous version and asks you to type the server identifier first.
