# vault-secretstore-controller

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
![version](https://img.shields.io/github/tag/IMIO/helm-vault-secretstore-controller.svg?label=release)
![test](https://github.com/IMIO/helm-vault-secretstore-controller/actions/workflows/test.yaml/badge.svg)
![release](https://github.com/IMIO/helm-vault-secretstore-controller/actions/workflows/release.yaml/badge.svg)

Helm chart for the per-cluster Vault SecretStore Controller (INFRA-6881).

The Controller reconciles `external-secrets-approle` `Secret`/`SecretStore`
pairs from Vault AppRole Role state: it polls Vault for AppRole Roles under
`auth/<approleBackend>/role/<clusterName>-<namespace>` and keeps a matching
`Secret` + `external-secrets.io` `SecretStore` in sync in each namespace.

## Installing

### Pull Helm release

```sh
helm repo add imio https://imio.github.io/helm-charts
helm repo update
```

### Verify the chart signature

Since release `3.0.1`, packaged charts are signed. See
[IMIO/helm-charts — Verify chart signatures](https://github.com/IMIO/helm-charts#verify-chart-signatures)
for how to verify.

### Install the chart

```sh
helm install vault-secretstore-controller imio/vault-secretstore-controller \
  --set clusterName=<cluster-name> \
  --set vaultAddr=https://vault.imio.be
```

or by cloning this repository:

```sh
git clone https://github.com/imio/helm-vault-secretstore-controller.git
cd helm-vault-secretstore-controller
helm install vault-secretstore-controller . \
  --set clusterName=<cluster-name> \
  --set vaultAddr=https://vault.imio.be
```

`clusterName` and `vaultAddr` are required and have no default — see
[Configuration](#configuration).

## Configuration

| Value | Required | Default | Description |
| --- | --- | --- | --- |
| `clusterName` | yes | — | This cluster's name, used as the Vault AppRole Role prefix. See below. |
| `vaultAddr` | yes | — | Vault server address, e.g. `https://vault.imio.be`. |
| `approleBackend` | no | binary default (`approle-externalsecrets`) | Vault AppRole auth backend mount path. |
| `pollInterval` | no | binary default (`1m`) | How often the Controller sweeps Vault for AppRole Role changes. |
| `image.repository` | no | `harbor.imio.be/infra/vault-secretstore-controller` | Controller image. |
| `image.tag` | no | `.Chart.AppVersion` | Image tag. |
| `image.pullPolicy` | no | `IfNotPresent` | Image pull policy. |
| `imagePullSecrets` | no | `[{name: harbor-secret}]` | Pull secrets for the Harbor registry. |
| `serviceAccount.create` | no | `true` | Create a ServiceAccount for the Controller. |
| `serviceAccount.name` | no | chart fullname | ServiceAccount name when `create` is `false`, or override when `true`. |
| `serviceAccount.annotations` | no | `{}` | Annotations on the created ServiceAccount. |
| `vaultAuth.tokenSecretName` | no | — | Name of an existing static-token Secret. See [Vault authentication](#vault-authentication). |
| `vaultAuth.tokenSecretKey` | no | `VAULT_TOKEN` | Key within that Secret. |
| `extraVolumes` | no | `[]` | Extra pod volumes, e.g. for mounting an internal CA bundle. |
| `extraInitContainers` | no | `[]` | Extra init containers, e.g. for fetching an internal CA bundle. |
| `extraVolumeMounts` | no | `[]` | Extra volume mounts on the Controller container. |
| `extraEnv` | no | `[]` | Extra environment variables on the Controller container, e.g. `VAULT_CACERT`. |
| `resources` | no | `{}` | Pod resource requests/limits. |

`clusterName` is used as the Vault AppRole Role prefix
(`auth/<approleBackend>/role/<clusterName>-<namespace>`). It is deliberately
not inferred from `.Release.Name`/`.Release.Namespace`, which are
user-controlled at install time, while cluster identity must not be.

## What the chart deploys

- A `Deployment` running a single replica (no leader election yet — more
  than one replica would run duplicate, conflicting reconciles).
- A `ServiceAccount` (when `serviceAccount.create` is `true`).
- A `ClusterRole`/`ClusterRoleBinding` granting the Controller `get`,
  `list`, `watch` on `namespaces`, and `get`, `list`, `watch`, `create`,
  `update`, `delete` on `Secret`s and `external-secrets.io` `SecretStore`s
  cluster-wide.

## Vault authentication

Until Kubernetes-auth login is implemented, the Controller authenticates to
Vault with a static token. Create the Secret yourself before installing:

```sh
kubectl create secret generic vault-token --from-literal=VAULT_TOKEN=<token>
```

then point the chart at it:

```sh
helm install vault-secretstore-controller . \
  --set clusterName=<cluster-name> \
  --set vaultAddr=https://vault.imio.be \
  --set vaultAuth.tokenSecretName=vault-token
```

## Contributing

Feel free to contribute by making a
[pull request](https://github.com/imio/helm-vault-secretstore-controller/pull/new/main).

Please read the official
[Helm Contribution Guide](https://github.com/helm/charts/blob/master/CONTRIBUTING.md)
from Helm for more information on how you can contribute to this Chart.

## License

[Apache License 2.0](/LICENSE)
