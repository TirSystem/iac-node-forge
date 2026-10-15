**English**

# Contabo read-only live test

The Contabo adapter has two kinds of tests. The normal tests run everywhere, including in
Gitea CI, against an in-process mock of the Contabo API. The **live tests** run the same
read-only adapter against your **real Contabo account**, so they confirm what a mock
cannot: the token exchange and the real shape of the answers.

The live tests are marked `integration` and are skipped unless the four Contabo variables
below are set, so they never run by accident and never run in CI.

## What the live tests do and do not do

- They **only read**: they get an access token and list data centers, images and instances.
- They **never create, change, start, stop, reinstall or cancel** an instance, so they cost
  nothing and cannot change your account.
- Your Contabo credentials stay in environment variables of your own shell. Do not write
  them in a file, a commit, a wiki page or a chat.

## 1. What you need

Four values from the Contabo customer control panel (the API section), as described in
Contabo's own documentation:

| Variable | Contabo's name for it |
| --- | --- |
| `CONTABO_CLIENT_ID` | Client ID |
| `CONTABO_CLIENT_SECRET` | Client secret |
| `CONTABO_API_USER` | API user |
| `CONTABO_API_PASSWORD` | API password |

`CONTABO_API_URL` is optional and defaults to `https://api.contabo.com`.

Also: Python 3.13 and the repository `iac-node-forge-py` with its virtual environment, as
in [part 2 of the Proxmox VE guide](Integration-Test-Run).

## 2. Set the variables

Run these in the `iac-node-forge-py` folder. The commands ask for each value without
showing it.

**Linux and macOS (bash)**

```bash
read -rsp "Client ID: " CONTABO_CLIENT_ID; echo; export CONTABO_CLIENT_ID
read -rsp "Client secret: " CONTABO_CLIENT_SECRET; echo; export CONTABO_CLIENT_SECRET
read -rp  "API user: " CONTABO_API_USER; export CONTABO_API_USER
read -rsp "API password: " CONTABO_API_PASSWORD; echo; export CONTABO_API_PASSWORD
```

**Windows (PowerShell)**

```powershell
$env:CONTABO_CLIENT_ID     = Read-Host "Client ID"
$env:CONTABO_CLIENT_SECRET = Read-Host "Client secret" -MaskInput
$env:CONTABO_API_USER      = Read-Host "API user"
$env:CONTABO_API_PASSWORD  = Read-Host "API password" -MaskInput
```

(`-MaskInput` needs PowerShell 7.)

## 3. Run

The same command in both shells:

```bash
pytest -m integration -k contabo -v
```

| Result | Meaning |
| --- | --- |
| all passed | The adapter works against your account. |
| skipped | One of the four variables is not set in this session. |
| a failure in `validate_access` | A value is wrong, or the API user has no access; the message names the step, never a value. |
| a failure in a list test | The real answer differs from the mock; report the test name. |

A failure is a useful result: it shows where the mock and the real service differ.

When you report a result, send the summary lines and the names of any failing tests. Never
send the credentials.

## 4. Clean up

**Linux and macOS (bash)**

```bash
unset CONTABO_CLIENT_ID CONTABO_CLIENT_SECRET CONTABO_API_USER CONTABO_API_PASSWORD CONTABO_API_URL
```

**Windows (PowerShell)**

```powershell
Remove-Item Env:CONTABO_CLIENT_ID, Env:CONTABO_CLIENT_SECRET, Env:CONTABO_API_USER, Env:CONTABO_API_PASSWORD, Env:CONTABO_API_URL -ErrorAction SilentlyContinue
```

Closing the terminal clears them too. If you want to rotate the credentials afterwards, do
it in the customer control panel.
