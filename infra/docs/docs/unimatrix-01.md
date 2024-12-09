# Unimatrix-01 (management cluster)

This is a small three node cluster deployed using the [Kube-Hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner) stack on Hetzner Cloud.
Building it in NixOS would be fun, but I do not have the time for that.

I use it for everything that is management related and for web stuff which is important and should not be subject to some experiments :)

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
