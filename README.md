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
### apply network config in mongo
```
any-sync-confapply -c /etc/any-sync-coordinator/config.yml -n /etc/any-sync-coordinator/network.yml -e
```

### Setup Requirements
* redis
* mongo

## Usage
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
