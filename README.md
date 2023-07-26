# anysync
## apply network config in mongo
```
any-sync-confapply -c /etc/any-sync-coordinator/config.yml -n /etc/any-sync-coordinator/network.yml -e
```
## show current config in mongo
```
use coordinator
db.nodeConf.find().sort( { _id: -1 } ).limit(1)
```
