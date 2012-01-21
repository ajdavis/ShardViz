echo Killing all mongod and mongos
killall mongod
killall mongos

cd /Users/emptysquare/10gen/tmp_shard
echo `pwd`

rm -rf shard* config mongos.log
mkdir shard0; touch shard0/log
mkdir shard1; touch shard1/log
mkdir config; touch config/log
touch mongos.log

mongod --dbpath shard0 --logpath shard0/log --port 4000 --fork
mongod --dbpath shard1 --logpath shard1/log --port 4001 --fork
mongod --dbpath config --logpath config/log --port 4002 --fork --configsvr
sleep 3 # let config server start up
mongos --configdb localhost:4002 --fork --logpath mongos.log --chunkSize 1
sleep 2
mongo admin <<EOF
db.runCommand( { addshard : 'localhost:4000', name: 'shard0' })
db.runCommand( { addshard : 'localhost:4001', name: 'shard1' })
db.runCommand({enablesharding:'test'});
db.runCommand({shardcollection:'test.sharded_collection', key:{'_id':1}});
var s = 's';
while (s.length < 262144) { var _ = (s += s); }
var test = db.getSisterDB('test');
for (var i = 0; i < 500; i++) { test.sharded_collection.insert({_id: i, s: s}); }
EOF
