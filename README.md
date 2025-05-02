# Puppet for any-sync
https://tech.anytype.io/

## Table of Contents

1. [Description](#description)
1. [Setup — The basics of getting started with template](#setup)
1. [Usage — Configuration options and additional functionality](#usage)
1. [Reference](#reference)

## Description
Module to configure a self-hosted setup for any-sync-* daemons.

## Setup
### Compatible versions
You can find compatible versions on these pages:
* stable versions, used in [production](https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/)
* unstable versions, used in [test stand](https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/)

### Example hiera configuration
```
---
classes:
  - anysync

# enable for relevant group of hosts {{
anysync::consensusnode: true
anysync::coordinator: true
anysync::filenode: true
anysync::node: true
# }}

pkg::any-sync-node: 0.2.12
pkg::any-sync-filenode: 0.3.6
pkg::any-sync-coordinator: 0.2.9
pkg::any-sync-consensusnode: 0.0.4

anysync::filenode::config::cfg:
  s3Store:
    region: eu-central-1
    profile: default
    bucket: s3BucketName
    maxThreads: 16
  redis:
    isCluster: true
    url: redis://redis1.local:6379?dial_timeout=3&read_timeout=6s&addr=redis1.local:6380&addr=redis3.local:6379&addr=redis3.local:6380&addr=redis2.local:6379&addr=redis2.local:6380

anysync::coordinator::config::cfg:
  mongo:
    connect: mongodb://coordinator-db1.local:27017,coordinator-db2.local:27017,coordinator-db3.local:27017
  fileLimit:
    limitDefault: 1073741824
    limitAlphaUsers: 10737418240
    limitNightlyUsers: 53687091200

anysync::consensusnode::config::cfg:
  mongo:
    connect: mongodb://coordinator-db1.local:27017,coordinator-db2.local:27017,coordinator-db3.local:27017/?w=majority # "w=majority" is required!

any_sync_accounts:
  # tree node {{
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
  # filenode
  filenode1.local:
    peerId: 12D3KooWJExfEKskv47BP77mrBV2ciCgZgkdZFrL5R1CQjU6DVb6
    peerKey: <secret>
    signingKey: <secret>
  # coordinator
  coordinator1.local:
    peerId: 12D3KooWRjnz8Ju1hFmY6SzoVYKXBVtqiQXGJkqQesQaRMpF2sVF
    peerKey: <secret>
    signingKey: <secret> # network signingKey
  # consensus
  consensusnode1.local:
    peerId: 12D3KooWBjCiYhk31PhdjG72M9oQKMbcyC3adsMbT7tMrmTi8KeB
    peerKey: <secret>
    signingKey: <secret> # network signingKey

anysync::filenode::config::aws_credentials:
  default:
    aws_access_key_id: <secret>
    aws_secret_access_key: <secret>

any_sync_network:
  networkId: N5787WrcATL3f9kDUVxz9yeexEoxxmBLQRhJ47SBNBXEhadc
  nodes:
    - peerId: 12D3KooWLTVK3VgXziU8ZcvvHUebueSBPiJNjXBxm3DQWtqsCbWD
      addresses:
        - node1.local:443
        - quic://node1.local:5430
      types: [tree]
    - peerId: 12D3KooWBTWo5KVveQuVEA4VeivgbS7LxGkTgmWspEtpaw3D5xXw
      addresses:
        - node2.local:443
        - quic://node2.local:5430
      types: [tree]
    - peerId: 12D3KooWF8HJnjL8MDUAExyg7yEAXhcXKzMwsn3dvivDjKWe7NN5
      addresses:
        - node3.local:443
        - quic://node3.local:5430
      types: [tree]
    - peerId: 12D3KooWJExfEKskv47BP77mrBV2ciCgZgkdZFrL5R1CQjU6DVb6
      addresses:
        - filenode1.local:443
        - quic://filenode1.local:5430
      types: [file]
    - peerId: 12D3KooWRjnz8Ju1hFmY6SzoVYKXBVtqiQXGJkqQesQaRMpF2sVF
      addresses:
        - coordinator1.local:443
        - quic://coordinator1.local:5430
      types: [coordinator]
    - peerId: 12D3KooWBjCiYhk31PhdjG72M9oQKMbcyC3adsMbT7tMrmTi8KeB
      addresses:
        - consensusnode1.local:443
        - quic://consensusnode1.local:5430
      types: [consensus]
```
### Secrets
* To generate keys, please use [any-sync-tools](https://github.com/anyproto/any-sync-tools)
* To encrypt secrets, please use [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml)

### Setup Requirements
* redis
* mongo

#### Puppet modules requirements
* [githubartifact](https://github.com/fb929/puppet-githubartifact)
* [puppet-systemd 4.1.0](https://github.com/voxpupuli/puppet-systemd)
* optional [syslog_ng](https://github.com/fb929/puppet-syslog-ng), minimum version v1.2.0
* optional [consul](https://github.com/voxpupuli/puppet-consul) + [tools](https://github.com/fb929/puppet-tools)
* optional [collectd](https://github.com/fb929/puppet-collectd)

## Usage
### Apply network config in Mongo
```
any-sync-confapply -c /etc/any-sync-coordinator/config.yml -n /etc/any-sync-coordinator/network.yml -e
```
### Ahow current config in Mongo
```
use coordinator
db.nodeConf.find().sort( { _id: -1 } ).limit(1)
```
or
```
mongosh coordinator --eval 'db.getMongo().setReadPref("primaryPreferred"); db.nodeConf.find().sort( { _id: -1 } ).limit(1)'
```

## [Reference](REFERENCE.md)
To update REFERENCE.md please run:
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
