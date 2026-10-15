**English**

# 2. Run the tests with pytest

Part 2 of 3 of the [real Proxmox VE integration test](Integration-Test). You need the
container and the token from [part 1](Integration-Test-Set-Up) and the variables
`PVE_TOKEN` and `PVE_VERIFY` set in the same PowerShell session.

## 2.1 Python environment (once)

In the `iac-node-forge-py` folder:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python --version        # 3.13.x
pip install -e ".[dev]"
```

`.venv` is ignored by git.

## 2.2 Check the variables

```powershell
$env:PVE_ADDRESS        # optional; empty means https://localhost:8006
$env:PVE_VERIFY         # false for the self-signed certificate
if ($env:PVE_TOKEN) { 'PVE_TOKEN is set' } else { 'PVE_TOKEN is missing' }
```

| Variable | Meaning | Default |
| --- | --- | --- |
| `PVE_TOKEN` | The full token `USER@REALM!TOKENID=SECRET`. Required. | none; the tests are skipped without it |
| `PVE_ADDRESS` | The address of the Proxmox VE | `https://localhost:8006` |
| `PVE_VERIFY` | `true`, `false` or the path of a CA bundle file | `true` |

## 2.3 Run

```powershell
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

The normal tests do not need the container:

```powershell
pytest
```

They deselect the integration tests. Run the whole set of checks the way CI does:

```powershell
ruff format --check .
ruff check .
mypy src tests
lint-imports
pytest -q
```

Next: [3. Take it down](Integration-Test-Take-Down).
