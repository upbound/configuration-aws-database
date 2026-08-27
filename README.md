# AWS Database Configuration

This repository contains an Upbound project, tailored for users establishing their initial control plane with [Upbound](https://cloud.upbound.io). This configuration deploys fully managed AWS database instances.

## Overview

The core components of a custom API in [Upbound Project](https://docs.upbound.io/learn/control-plane-project/) include:

- **CompositeResourceDefinition (XRD):** Defines the API's structure.
- **Composition(s):** Configures the Functions Pipeline
- **Embedded Function(s):** Encapsulates the Composition logic and implementation within a self-contained, reusable unit

In this specific configuration, the API contains:

- **an [AWS Database](/apis/definition.yaml) custom resource type.**
- **Composition:** Configured in [/apis/composition.yaml](/apis/composition.yaml)
- **Embedded Function:** The Composition logic is encapsulated within [embedded function](/functions/sqlinstance/main.k)

## Connecting to the database

Each `SQLInstance` writes its credentials to a Secret named
`<SQLInstance name>-sql`, in the `SQLInstance`'s own namespace. That name is
part of this configuration's interface; consumers can rely on it.

| Key | Value |
|---|---|
| `endpoint` | `host:port` |
| `address` | Hostname |
| `host` | Hostname (a duplicate of `address`) |
| `port` | Port |
| `username` | Master username |
| `password` | Master password |

The Secret is written by the RDS managed resource the composition creates, so
it appears once that instance is available — roughly ten minutes after the
`SQLInstance` is applied. A workload can reference it before then; pods wait in
`CreateContainerConfigError` and start on kubelet's own retry once it exists.

Note that a `SQLInstance` does **not** publish Crossplane connection details of
its own. It is a namespaced `apiextensions.crossplane.io/v2` composite, and
Crossplane does not support connection secrets for those — there is no
`writeConnectionSecretToRef` on the composite, and its publisher is a no-op.
The Secret above is the only mechanism.

## Testing

The configuration can be tested using:

- `up composition render --xrd=apis/definition.yaml apis/composition.yaml examples/mariadb-xr.yaml` to render the MariaDB composition
- `up composition render --xrd=apis/definition.yaml apis/composition.yaml examples/postgres-xr.yaml` to render the PostgreSQL composition
- `up test run tests/*` to run composition tests
- `up test run tests/* --e2e` to run end-to-end tests

## Deployment

- Execute `up project run`
- Alternatively, install the Configuration from the [Upbound Marketplace](https://marketplace.upbound.io/configurations/upbound/configuration-aws-database)
- Check [examples](/examples/) for example XR(Composite Resource)

## Next steps

This repository serves as a foundational step. To enhance the configuration, consider:

1. create new API definitions in this same repo
2. editing the existing API definition to your needs

To learn more about how to build APIs for your managed control planes in Upbound, read the guide on [Upbound's docs](https://docs.upbound.io/).