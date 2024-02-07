# AWS Database Configuration


This repository contains a [Crossplane configuration](https://docs.crossplane.io/latest/concepts/packages/#configuration-packages), tailored for users establishing their initial control plane with [Upbound](https://cloud.upbound.io). This configuration deploys fully managed [AWS database](https://aws.amazon.com/getting-started/decision-guides/databases-on-aws-how-to-choose/) instances.

## Overview

The core components of a custom API in [Crossplane](https://docs.crossplane.io/latest/getting-started/introduction/) include:

- **CompositeResourceDefinition (XRD):** Defines the API's structure.
- **Composition(s):** Implements the API by orchestrating a set of Crossplane managed resources.

In this specific configuration, the AWS database API contains:

- **a [database](/apis/definition.yaml) custom resource type.**
- **Composition of the database resources:** Configured in [/apis/composition.yaml](/apis/composition.yaml), it provisions AWS database resources in the `upbound-system` namespace.

This repository contains an Composite Resource (XR) file.

## Deployment

```shell
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: configuration-aws-database
spec:
  package: xpkg.upbound.io/upbound/configuration-aws-database:v0.7.0
```

## Next steps

This repository serves as a foundational step. To enhance your control plane, consider:

1. create new API definitions in this same repo
2. editing the existing API definition to your needs


Upbound will automatically detect the commits you make in your repo and build the configuration package for you. To learn more about how to build APIs for your managed control planes in Upbound, read the guide on Upbound's docs.
