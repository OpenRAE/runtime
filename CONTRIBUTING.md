# Contribute

Use Go 1.27.3, the toolchain admitted by OpenRAE/rae.
Pull requests target the protected `dev` integration branch.
Link each pull request to its issue and the applicable canonical RAE requirements.
Use a Conventional Commit title and explain the change and verification.
`@Brad-Edwards` owns repository and security decisions.

Install Vale 3.15.2 for the existing prose rules.
Run `make tools` once to build the pinned checks.
Run `make check` for compilation, lint, architecture and module checks.
Run selected tests with `make test PACKAGE=./path/to/package TEST=TestName`.
The bootstrap has no runtime implementation or behavior tests yet.
CI owns the full race, coverage, regression, fuzz and mutation runs.
The 90% statement coverage floor applies when executable statements exist.

Follow the unchanged [Go standards](docs/decisions/adrs/adr-121-go-engineering-standards.md)
and [architecture rules](docs/decisions/adrs/adr-122-go-architecture-model.md).
Runtime consumes public RAE APIs; it does not copy their semantic implementation.
The existing split is described in [the architecture reference](docs/architecture.md).

Run `grndctl doctor` from this checkout to check Ground Control setup.
`.mcp.json` starts the installed `grndctl mcp` here.
Credentials stay in ignored `.env`; the bootstrap needs no publishing credentials.
SonarCloud must use a runtime-specific project before runtime source is imported.
No SDL project or token is copied by this bootstrap.
Normal publication remains disabled until OpenRAE/rae#1804.
