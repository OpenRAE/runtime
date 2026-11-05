# Runtime agent rules

Use `.ground-control.yaml` through `gc_get_repo_ground_control_context` before implementation.
The Ground Control project is `runtime`; this repository is `OpenRAE/runtime`.
Start the agent and `grndctl mcp` from this checkout, so repository authorization matches.

Read `CONTRIBUTING.md`, `docs/architecture.md`, and `.gc/plan-rules.md`.
The accepted split documents govern the design. Do not add to the design during repository setup or extraction.
Run targeted tests locally. Full, integration, fuzz and mutation suites run in CI only.
Keep secrets in ignored local configuration. Never copy credentials from the SDL repository.
Do not publish runtime artifacts before OpenRAE/rae#1804.
Use native issue/feature branch names and Conventional Commit PR titles. Merge requires maintainer approval.
