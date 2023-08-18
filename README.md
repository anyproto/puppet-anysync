# anysync
https://tech.anytype.io/

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with template](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference](#reference)

## Description
module for configure self-hosted setup any-sync-* daemons

## Setup
### compatible versions
you can find compatible versions on this pages:
* stable versions, used in production - https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/
* unstable versions, used in test stand - https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/

### example hiera configuration
```
---
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
    connect: mongodb://coordinator-db1.local:27017,coordinator-db2.local:27017,coordinator-db3.local:27017/?w=majority

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
      types: [tree]
    - peerId: 12D3KooWBTWo5KVveQuVEA4VeivgbS7LxGkTgmWspEtpaw3D5xXw
      addresses:
        - node2.local:443
      types: [tree]
    - peerId: 12D3KooWF8HJnjL8MDUAExyg7yEAXhcXKzMwsn3dvivDjKWe7NN5
      addresses:
        - node3.local:443
      types: [tree]
    - peerId: 12D3KooWJExfEKskv47BP77mrBV2ciCgZgkdZFrL5R1CQjU6DVb6
      addresses:
        - filenode1.local:443
      types: [file]
    - peerId: 12D3KooWRjnz8Ju1hFmY6SzoVYKXBVtqiQXGJkqQesQaRMpF2sVF
      addresses:
        - coordinator1.local:443
      types: [coordinator]
    - peerId: 12D3KooWBjCiYhk31PhdjG72M9oQKMbcyC3adsMbT7tMrmTi8KeB
      addresses:
        - consensusnode1.local:443
      types: [consensus]
```
### secrets
* for generating keys please use [any-sync-tools](https://github.com/anyproto/any-sync-tools)
* for encrypting secrets please use [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml)

### Setup Requirements
* redis
* mongo

## Usage
### apply network config in mongo
```
any-sync-confapply -c /etc/any-sync-coordinator/config.yml -n /etc/any-sync-coordinator/network.yml -e
```
### show current config in mongo
```
use coordinator
db.nodeConf.find().sort( { _id: -1 } ).limit(1)
```

## [Reference](REFERENCE.md)
for update REFERENCE.md please run:
```
puppet strings generate --format markdown
```
