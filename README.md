# Puppet for any-sync
https://tech.anytype.io/

Puppet module that installs, configures and runs self-hosted any-sync daemons:
`any-sync-node`, `any-sync-filenode`, `any-sync-coordinator`, `any-sync-consensusnode` and `any-ns-node`.

## Table of Contents
1. [Requirements](#requirements)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Reference](#reference)
1. [Contribution](#contribution)

## Requirements
* Puppet 7, RPM-based OS (packages are downloaded as `.rpm` from GitHub releases)
* MongoDB >= 4 in Replica Set mode — for coordinator, consensusnode and ns
* Redis with the [Bloom](https://github.com/RedisBloom/RedisBloom) module — for filenode
* S3-compatible storage (AWS S3, [Garage](https://garagehq.deuxfleurs.fr/), etc.) — for filenode

Puppet modules:
* [puppetlabs-stdlib](https://github.com/puppetlabs/puppetlabs-stdlib) >= 8.5.0
* [puppet-systemd](https://github.com/voxpupuli/puppet-systemd) >= 4.1.0
* [githubartifact](https://github.com/fb929/puppet-githubartifact)
* optional: [syslog_ng](https://github.com/fb929/puppet-syslog-ng) >= v1.2.0 (`anysync::syslog_ng`)
* optional: [consul](https://github.com/voxpupuli/puppet-consul) + [tools](https://github.com/fb929/puppet-tools), [collectd](https://github.com/fb929/puppet-collectd) (`anysync::monitoring`)

## Setup
### Versions
Default package versions are pinned in [data/common.yaml](data/common.yaml) (`pkg::*` keys) and can be overridden in your hiera.
Compatible version sets:
* stable, used in [production](https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/)
* unstable, used in [test stand](https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/)

### Secrets
* Generate keys with [any-sync-tools](https://github.com/anyproto/any-sync-tools)
* Encrypt secrets with [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml)

### Example hiera configuration
Every daemon is disabled by default; enable the ones you need per host group.
Defaults for each daemon live in [data/common/](data/common/).

```yaml
---
classes:
  - anysync

# enable for relevant group of hosts {{
anysync::consensusnode: true
anysync::coordinator: true
anysync::filenode: true
anysync::node: true
# }}

github_token: <secret> # used to download release packages

anysync::filenode::config::cfg:
  s3Store:
    region: eu-central-1
    profile: default
    bucket: s3BucketName
    maxThreads: 16
  redis:
    isCluster: true
    url: redis://redis1.local:6379?dial_timeout=3&read_timeout=6s&addr=redis1.local:6380&addr=redis2.local:6379&addr=redis2.local:6380&addr=redis3.local:6379&addr=redis3.local:6380

anysync::filenode::config::aws_credentials:
  default:
    aws_access_key_id: <secret>
    aws_secret_access_key: <secret>

anysync::coordinator::config::cfg:
  mongo:
    connect: mongodb://coordinator-db1.local:27017,coordinator-db2.local:27017,coordinator-db3.local:27017

anysync::consensusnode::config::cfg:
  mongo:
    connect: mongodb://coordinator-db1.local:27017,coordinator-db2.local:27017,coordinator-db3.local:27017/?w=majority # "w=majority" is required!

# keys of every node, picked by hostname
any_sync_accounts:
  # tree nodes {{
  node1.local:
    peerId: 12D3KooWLTVK3VgXziU8ZcvvHUebueSBPiJNjXBxm3DQWtqsCbWD
    peerKey: <secret>
    signingKey: <secret>
  node2.local:
    peerId: 12D3KooWBTWo5KVveQuVEA4VeivgbS7LxGkTgmWspEtpaw3D5xXw
    peerKey: <secret>
    signingKey: <secret>
  node3.local:
    peerId: 12D3KooWF8HJnjL8MDUAExyg7yEAXhcXKzMwsn3dvivDjKWe7NN5
    peerKey: <secret>
    signingKey: <secret>
  # }}
  filenode1.local:
    peerId: 12D3KooWJExfEKskv47BP77mrBV2ciCgZgkdZFrL5R1CQjU6DVb6
    peerKey: <secret>
    signingKey: <secret>
  coordinator1.local:
    peerId: 12D3KooWRjnz8Ju1hFmY6SzoVYKXBVtqiQXGJkqQesQaRMpF2sVF
    peerKey: <secret>
    signingKey: <secret> # network signingKey
  consensusnode1.local:
    peerId: 12D3KooWBjCiYhk31PhdjG72M9oQKMbcyC3adsMbT7tMrmTi8KeB
    peerKey: <secret>
    signingKey: <secret> # network signingKey

# network config shared by all daemons
any_sync_network:
  networkId: N5787WrcATL3f9kDUVxz9yeexEoxxmBLQRhJ47SBNBXEhadc
  nodes:
    - peerId: 12D3KooWLTVK3VgXziU8ZcvvHUebueSBPiJNjXBxm3DQWtqsCbWD
      addresses: [node1.local:443, quic://node1.local:5430]
      types: [tree]
    - peerId: 12D3KooWBTWo5KVveQuVEA4VeivgbS7LxGkTgmWspEtpaw3D5xXw
      addresses: [node2.local:443, quic://node2.local:5430]
      types: [tree]
    - peerId: 12D3KooWF8HJnjL8MDUAExyg7yEAXhcXKzMwsn3dvivDjKWe7NN5
      addresses: [node3.local:443, quic://node3.local:5430]
      types: [tree]
    - peerId: 12D3KooWJExfEKskv47BP77mrBV2ciCgZgkdZFrL5R1CQjU6DVb6
      addresses: [filenode1.local:443, quic://filenode1.local:5430]
      types: [file]
    - peerId: 12D3KooWRjnz8Ju1hFmY6SzoVYKXBVtqiQXGJkqQesQaRMpF2sVF
      addresses: [coordinator1.local:443, quic://coordinator1.local:5430]
      types: [coordinator]
    - peerId: 12D3KooWBjCiYhk31PhdjG72M9oQKMbcyC3adsMbT7tMrmTi8KeB
      addresses: [consensusnode1.local:443, quic://consensusnode1.local:5430]
      types: [consensus]
```

## Usage
### First deploy
The order matters: the coordinator must know the network before other daemons connect to it.

1. **Prepare dependencies.** MongoDB replica set, Redis with Bloom, S3 bucket and credentials.
1. **Generate the network.** With [any-sync-network](https://github.com/anyproto/any-sync-tools/blob/main/any-sync-network/README.md)
   create the network and nodes (at least 3 `tree`, 1 `coordinator`, 1 `file`, 1 `consensus`).
   Put keys into `any_sync_accounts`, nodes into `any_sync_network`, and keep the generated `client.yml` for clients.
   The coordinator and consensusnode use the network `signingKey`.
1. **Deploy the coordinator.** Run puppet on the coordinator hosts. It writes
   `/etc/any-sync-coordinator/config.yml` and `network.yml` and starts the service.
1. **Apply the network config to Mongo.** On a coordinator host, once:
   ```
   any-sync-confapply -c /etc/any-sync-coordinator/config.yml -n /etc/any-sync-coordinator/network.yml -e
   ```
1. **Deploy the other daemons.** Run puppet on the tree nodes, consensusnode and filenode hosts (any order).
1. **Check connectivity.** Run [any-sync-netcheck](https://github.com/anyproto/any-sync-tools) with `client.yml`.
1. **Connect clients.** Import `client.yml` into the Anytype app,
   see [self-hosting docs](https://doc.anytype.io/anytype-docs/data-and-security/self-hosting#switching-between-networks).

### Changing the network (adding nodes, changing addresses)
1. Update `any_sync_accounts` / `any_sync_network` in hiera.
1. Run puppet on the coordinator, then run `any-sync-confapply` again.
1. Run puppet on the rest of the hosts.
1. Give clients the updated `client.yml`.

### Upgrading
1. Pick a version set from [compatible versions](#versions) and update `pkg::*` keys.
1. Roll out: coordinator first, then consensusnode, filenode and tree nodes one by one.

### Show current network config in Mongo
```
mongosh coordinator --eval 'db.getMongo().setReadPref("primaryPreferred"); db.nodeConf.find().sort( { _id: -1 } ).limit(1)'
```

## Reference
All classes and parameters are documented in [REFERENCE.md](REFERENCE.md). To regenerate it:
```
puppet strings generate --format markdown
```

## Contribution
Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](https://github.com/anyproto/.github/blob/main/docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](https://github.com/anyproto/.github/blob/main/docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](https://github.com/anyproto/.github/blob/main/docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [MIT](./LICENSE.md).
