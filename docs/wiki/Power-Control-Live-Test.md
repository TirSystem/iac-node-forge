**English**

# Power control live test

> **This test turns a real server off and on.** Run it only against a **disposable**
> server: a Proxmox VE virtual machine or container, or a Contabo instance, that you can
> afford to stop. It never creates, deletes, cancels, reinstalls or snapshots anything and
> it puts the server back in the state it found it in, but a server that is stopped is
> stopped, and a Contabo instance keeps its contract either way.

The live tests act through the same use cases and adapters as the command line:
`ControlServerPower` and `TrackOperation` with the real Proxmox VE or Contabo adapter. They
are marked `integration`, are skipped unless **everything** below is set, and never run in
CI.

## What the scenario does

If the server is **running** when the test starts:

1. Ask for a graceful shutdown, follow the operation, expect `succeeded` and a stopped
   server.
2. Start it, follow the operation, expect `succeeded` and a running server.
3. Restart it, follow the operation, expect `succeeded` and a running server.
4. Ask to start it again and expect "already in the requested state" with **no request**.

If the server is **stopped** when it starts, the test starts it, runs the checks above and
shuts it down again at the end. A finalizer restores the original state even when an
assertion fails.

A hard stop (`stop`, which can lose unsaved data) is a separate test that needs one more
variable.

## 1. Choose the disposable server

- **Proxmox VE:** the numeric `vmid` of the virtual machine or container, on the Proxmox VE
  you already use for the [read-only live test](Integration-Test).
- **Contabo:** the numeric instance id, in the account of the
  [read-only live test](Contabo-Live-Test).

## 2. Set the variables

Run these in the `iac-node-forge-py` folder, in the same session as your virtual
environment. Nothing is written to a file; secrets are read without echo.

### Proxmox VE

The existing `PVE_TOKEN`, and optionally `PVE_ADDRESS` and `PVE_VERIFY`, as in the
[read-only guide](Integration-Test-Run). The token's user needs the `VM.PowerMgmt`
permission on the server. Then the two power variables:

**Linux and macOS (bash)**

```bash
export PVE_POWER_TEST_SERVER=<vmid>
export PVE_POWER_TEST_CONFIRM=turn-off-server-<vmid>
```

**Windows (PowerShell)**

```powershell
$env:PVE_POWER_TEST_SERVER  = '<vmid>'
$env:PVE_POWER_TEST_CONFIRM = 'turn-off-server-<vmid>'
```

### Contabo

The four `CONTABO_` variables of the [read-only guide](Contabo-Live-Test), and then:

**Linux and macOS (bash)**

```bash
export CONTABO_POWER_TEST_SERVER=<instance id>
export CONTABO_POWER_TEST_CONFIRM=turn-off-server-<instance id>
```

**Windows (PowerShell)**

```powershell
$env:CONTABO_POWER_TEST_SERVER  = '<instance id>'
$env:CONTABO_POWER_TEST_CONFIRM = 'turn-off-server-<instance id>'
```

The confirmation text must contain the server id exactly. This is deliberate: a copied
variable for another server does not match, and the test is skipped.

## 3. Run

The same commands in both shells:

```bash
pytest -m integration -k "power and proxmox" -v
pytest -m integration -k "power and contabo" -v
```

| Result | Meaning |
| --- | --- |
| passed | The operation was followed to its end and the server is back as it was. |
| skipped, "confirmation text does not match" | The confirm variable is wrong; nothing was touched. |
| skipped, a list of variable names | Those variables are not set in this session. |
| a failure in a step | Look at the server's state in the provider's console first; the finalizer will have tried to restore it. |

Report the summary lines and the names of failing tests. Never send a token, a password or
the confirmation text.

## 4. Hard stop (optional)

`stop` powers the server off at once, as when the power is cut. It is a separate test that
runs only with:

**Linux and macOS (bash)**

```bash
export POWER_TEST_ALLOW_HARD_STOP=1
```

**Windows (PowerShell)**

```powershell
$env:POWER_TEST_ALLOW_HARD_STOP = '1'
```

## 5. Clean up

**Linux and macOS (bash)**

```bash
unset PVE_POWER_TEST_SERVER PVE_POWER_TEST_CONFIRM CONTABO_POWER_TEST_SERVER CONTABO_POWER_TEST_CONFIRM POWER_TEST_ALLOW_HARD_STOP
```

**Windows (PowerShell)**

```powershell
Remove-Item Env:PVE_POWER_TEST_SERVER, Env:PVE_POWER_TEST_CONFIRM, Env:CONTABO_POWER_TEST_SERVER, Env:CONTABO_POWER_TEST_CONFIRM, Env:POWER_TEST_ALLOW_HARD_STOP -ErrorAction SilentlyContinue
```

Also clear the provider variables as described in the earlier guides when you are done.
