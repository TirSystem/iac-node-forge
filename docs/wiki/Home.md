**English**

# iac-node-forge

iac-node-forge manages servers at Proxmox VE and Contabo from a command-line client
(Python) and, later, a WinUI 3 application.

## Guides

- [Real Proxmox VE integration test](Integration-Test) — run the read-only test suite
  against a real Proxmox VE in a container on your own machine.
  - [1. Set up the container](Integration-Test-Set-Up)
  - [2. Run the tests with pytest](Integration-Test-Run)
  - [3. Take it down](Integration-Test-Take-Down)
- [Contabo read-only live test](Contabo-Live-Test) — run the read-only tests against
  your own Contabo account (nothing is created or changed).
- [Power control live test](Power-Control-Live-Test) — turn a **disposable** server off and on
  through the product, at Proxmox VE or Contabo.
- [Provisioning live test](Provision-Live-Test) — create a container in the **throw-away** Docker Proxmox VE
  through the product, then delete it again.

## Appendix

- [Project documentation](Appendix-Documentation) — links to every document under `docs/`.
