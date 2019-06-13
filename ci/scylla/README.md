### Setup 2 nodes scylla cluster with ssl support

Create docker containers, require docker installed.

``` text
sh setup_node.sh
sh generate_ca_key.sh
sh generate_db_key.sh ssl-1
sh generate_db_key.sh ssl-2
sh create_ssl_instance.sh ssl-1 "-p 9044:9042 -p 9164:9160"
sh create_ssl_instance.sh ssl-2 "-p 9045:9042 -p 9165:9160" "--seeds $(docker inspect --format='{{ .NetworkSettings.Networks.database.IPAddress }}' db-ssl-1)"
```

Confirm node status.

``` text
docker logs db-ssl-1 | tail
docker exec -it db-ssl-1 nodetool status
docker logs db-ssl-2 | tail
docker exec -it db-ssl-2 nodetool status
```

Run cqlsh.

``` text
docker exec -it db-ssl-1 cqlsh --ssl
docker exec -it db-ssl-2 cqlsh --ssl
```

### Setup 2 nodes scylla cluster with ssl support (different host machine)

Create docker containers, require docker installed.

``` text
FIRST_IP="192.168.18.131"
SECOND_IP="192.168.18.132"
sh setup_node.sh
sh generate_ca_key.sh
sh generate_db_key.sh pub-ssl-1
sh generate_db_key.sh pub-ssl-2
sh create_ssl_instance.sh pub-ssl-1
  "-p 9042:9042 -p 7000:7000 -p 7001:7001 -p 9160:9160" \
  "--broadcast-address ${FIRST_IP} --broadcast-rpc-address ${FIRST_IP}"
sh create_ssl_instance.sh pub-ssl-2
  "-p 9042:9042 -p 7000:7000 -p 7001:7001 -p 9160:9160" \
  "--broadcast-address ${SECOND_IP} --broadcast-rpc-address ${SECOND_IP} --seeds ${FIRST_IP}"
```

### Setup single node scylla instance without ssl support

Create docker containers, require docker installed.

``` text
docker run \
  --name "db-simple" \
  --hostname "db-simple" \
  --restart always \
  -p 9043:9042 \
  -p 9163:9160 \
  -d scylladb/scylla
```

### CQL examples

Create new user and drop the default one,
execute on one node is enough,
but should check `system_auth.roles` table on each nodes.

``` text
alter keyspace system_auth with replication = { 'class': 'SimpleStrategy', 'replication_factor': 2 };
create user scylla with password 'scylla' superuser;
alter user scylla with password 'scylla';
drop user cassandra;

use system_auth;
describe tables;
select * from roles;
```

Create table and check replication.

``` text
create keyspace testdb with replication = { 'class': 'SimpleStrategy', 'replication_factor': 2 };
describe keyspaces;
use testdb;

create table testtable (id int, name text, remark text, primary key (id, name));
describe tables;

insert into testtable (id, name, remark) values (1, 'foo', 'some remark');
insert into testtable (id, name, remark) values (2, 'bar', 'other remark');
insert into testtable (id, name, remark) values (3, 'baz', null);
select * from testtable;
select id, name from testtable where id = 1;
select id, name from testtable where id = 1 and name = 'foo';
update testtable set remark = 'new remark' where id = 3 and name = 'baz';
delete from testtable where id = 1 and name = 'foo';
```

### Backup and restore

Test node down and up.

``` text
# node 1
supervisorctl stop scylla

# node 2
cqlsh --ssl -e "insert into testdb.testtable (id, name, remark) values (1, 'test failover', null);"
cqlsh --ssl -e "select * from testdb.testtable;"

# node 1
supervisorctl start scylla
nodetool status
cqlsh --ssl -e "select * from testdb.testtable;"
# should automatically apply changes after node is up
# to streaming data from other nodes, run this command
nodetool rebuild
```

Backup and restore node data, should execute on each nodes.

``` text
# backup
cqlsh --ssl -e "desc schema;" > db_schema.cql
nodetool snapshot testdb
ls /var/lib/scylla/data/testdb/testtable-f42f182009d211e9a17d000000000002/snapshots

# restore
cqlsh --ssl -e "source 'db_schema.cql';"
supervisorctl stop scylla
rm -rfv /var/lib/scylla/commitlog/*
cd /var/lib/scylla/data/testdb/testtable-f42f182009d211e9a17d000000000002
rm -fv ./*
cp -rfv ./snapshots/1545914209406/* .
supervisorctl start scylla

# remove backups
nodetool clearsnapshot testdb

# cleanup keys
nodetool cleanup
```

Backup and restore table data, execute on one node is enough.

``` text
copy testdb.testtable to 'testtable.csv';
truncate testdb.testtable;
copy testdb.testtable from 'testtable.csv';
select * from testdb.testtable;
```

### Links

- [nodetool](http://docs.scylladb.com/nodetool)
- [operating-scylla](http://docs.scylladb.com/operating-scylla)
- [cql](http://docs.scylladb.com/using-scylla/cql)
- [backup](http://docs.scylladb.com/procedures/backup)
- [restore](http://docs.scylladb.com/procedures/restore)
- [delete_snapshot](http://docs.scylladb.com/procedures/delete_snapshot)
