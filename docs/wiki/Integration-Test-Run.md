**English**

# 2. Run the tests with pytest

Part 2 of 3 of the [real Proxmox VE integration test](Integration-Test). You need the
container and the token from [part 1](Integration-Test-Set-Up), and the variables
`PVE_TOKEN` and `PVE_VERIFY` set in the same shell session.

Every command is given for **Linux and macOS (bash)** and **Windows (PowerShell)**. Run
them in the `iac-node-forge-py` folder.

## 2.1 Python environment (once)

**Linux and macOS (bash)**

```bash
python3 -m venv .venv
source .venv/bin/activate
python --version        # 3.13.x
pip install -e ".[dev]"
```

**Windows (PowerShell)**

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python --version        # 3.13.x
pip install -e ".[dev]"
```

`.venv` is ignored by git.

## 2.2 Check the variables

**Linux and macOS (bash)**

```bash
echo "PVE_ADDRESS=${PVE_ADDRESS:-<default>}"
echo "PVE_VERIFY=${PVE_VERIFY:-<unset>}"
[ -n "$PVE_TOKEN" ] && echo "PVE_TOKEN is set" || echo "PVE_TOKEN is missing"
```

**Windows (PowerShell)**

```powershell
"PVE_ADDRESS=$env:PVE_ADDRESS"        # empty means https://localhost:8006
"PVE_VERIFY=$env:PVE_VERIFY"
if ($env:PVE_TOKEN) { 'PVE_TOKEN is set' } else { 'PVE_TOKEN is missing' }
```

| Variable | Meaning | Default |
| --- | --- | --- |
| `PVE_TOKEN` | The full token `USER@REALM!TOKENID=SECRET`. Required. | none; the tests are skipped without it |
| `PVE_ADDRESS` | The address of the Proxmox VE | `https://localhost:8006` |
| `PVE_VERIFY` | `true`, `false` or the path of a CA bundle file | `true` |

## 2.3 Run

The same command in both shells:

```bash
pytest -m integration -v
```

## 2.4 Read the result

| Result | Meaning |
| --- | --- |
| `8 passed` | The adapter works against a real Proxmox VE. |
| `8 skipped` | `PVE_TOKEN` is not set in this session. |
| a failure in `validate_access` | The token header or the token is wrong. |
| a failure in `list_server_options` or `list_servers` | The real answer differs from the mock; report the test name. |

A failure is a useful result: it shows where the mock and the real server differ.

When you report a result, send the summary lines and the names of the failing tests. Never
send the token or the password.

## 2.5 The normal tests

The normal tests do not need the container. The command is the same in both shells:

```bash
pytest
```

They deselect the integration tests. To run all the checks the way CI does:

```bash
ruff format --check .
ruff check .
mypy src tests
lint-imports
pytest -q
```

Next: [3. Take it down](Integration-Test-Take-Down).
