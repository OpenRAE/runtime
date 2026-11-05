# Runtime plan rules

- Follow the existing RAE runtime split boundary and its public API commitments. Do not add features during extraction.
- Keep canonical SDL, processor, contract, backend and shared primitive authority in OpenRAE/rae. Runtime consumes its public APIs.
- Name the owning module and public interface for changed code. Update implementations/architecture.json before changing package boundaries.
- Keep requirement and source links against immutable OpenRAE/rae revisions. Do not copy the canonical requirements or published schemas.
- Run targeted tests locally with explicit PACKAGE and TEST selections. Full, integration, fuzz and mutation suites run in CI only.
- Preserve the Go engineering, architecture, security, regression and mutation checks of ADR-121 and ADR-122.
- Keep build/test jobs read-only and credential-free. Do not copy SDL publishing credentials, Ground Control project IDs or SonarCloud identities.
- Keep normal publication disabled until OpenRAE/rae#1804. Do not add services or publication destinations.
- Preserve source licences, notices, authorship and published evidence. Never rewrite or force-push source history.
