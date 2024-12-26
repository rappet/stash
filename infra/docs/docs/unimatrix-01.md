# Unimatrix-01 (management cluster)

This is my geographical distributed cluster.
I host some nodes in the cloud and some at home.
The cluster uses Tailscale VPN to mesh between multiple nodes
and also to expose internal services to my personal devices.

## Deployment

K3S on Fedora. Check [the Firewall Requirements for K3S](https://docs.k3s.io/installation/requirements?os=rhel).

Before installing, setup up the config file at `/etc/rancher/k3s/config.yaml`

```yaml
# /etc/rancher/k3s/config.yaml
tls-san:
  - "unimatrix-01.rappet.xyz"
cluster-init: true
# we use SQLite for the single node cluster as it makes backups simpler
cluster-cidr: 10.42.0.0/16,2a0e:46c6:0:7900::/56
service-cidr: 10.43.0.0/16,2a0e:46c6:0:7a00::/108
flannel-ipv6-masq: true
selinux: true
```

Installation can be done as described by their docs:

```shell
curl -sfL https://get.k3s.io | sh -
```

## Management related stuff

### [ArgoCD (TODO)](https://argocd.rappet.xyz)

### [Authelia (SSO, TODO)](https://sso.rappet.xyz)

Also used by other projects.

### [Graphana / Postgres (TODO)](https://graphana.rappet.xyz)

### [Object Storage (MinIO, TODO)](https://s3.rappet.xyz)

This is a three times replicated object storage only used for small important data.
The S3 managed by Hetzner is only region local, so if the data center park containing it would shut down or Putin snips more subsea cables, access to it would not be possible anymore.

### [Headscale](https://headscale.rappet.xyz)

Hardware nodes at home need Tailscale as this would make connecting them to eachother and nodes in the cloud far more easy and robust.

It is currently running on the [Services Host](/services-host)

## Applications

### [Hedgedoc](https://md.rappet.xyz)

It is currently running on the [Services Host](/services-host)

Beware: SSO is only possible using my forgejo instance.

### "Cloud" (some file storage, todo)
