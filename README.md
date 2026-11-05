# Runtime

Conformant reference runtime for controlling OpenRÆ scenarios and backends.

This repository will receive the existing Go runtime.
It will own execution, the control plane and HTTP API, stores, workers, and the combined `raes` executable.
SDL, processor, contract and portable backend APIs stay in [OpenRAE/rae](https://github.com/OpenRAE/rae).
The split keeps the same behavior.

See [the architecture reference](docs/architecture.md), [contribution guide](CONTRIBUTING.md),
and [bootstrap issue](https://github.com/OpenRAE/rae/issues/1893).
The Go module is `github.com/OpenRAE/runtime/implementations/go`.
No runtime implementation is imported yet.
Releases stay off until the [coordinated Go launch](https://github.com/OpenRAE/rae/issues/1804).
