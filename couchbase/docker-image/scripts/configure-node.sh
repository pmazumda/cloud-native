#!/bin/bash

USER=${CB_USER:-admin}
PASSWORD=${CB_PSWD:-p@ssw0rd}
HOST=${CB_HOST:-localhost}

# Enables job control
set -m

# Enables error propagation
set -e

# Run the server and send it to the background
/entrypoint.sh couchbase-server &

# Check if couchbase server is up
check_db() {
  curl --silent http://127.0.0.1:8091/pools > /dev/null
  echo $?
}

# Variable used in echo
i=1
# Echo with
log() {
  echo "[$i] [$(date +"%T")] $@"
  i=`expr $i + 1`
}

# Wait until it's ready
until [[ $(check_db) = 0 ]]; do
  >&2 log "Waiting for Couchbase Server to be available ..."
  sleep 1
done

# Initialize Cluster, Setup index and memory quotas


log "$(date +"%T") Init cluster ........."
couchbase-cli cluster-init -c 127.0.0.1 --cluster-username admin --cluster-password p@ssw0rd \
  --cluster-name myCluster --cluster-ramsize 1024 --cluster-index-ramsize 1024 --services data,index,query,fts \
  --index-storage-setting default

sleep 10
log "$(date +"%T") Cluster Initialized........."

# Create user
log "$(date +"%T") Create users ........."

couchbase-cli user-manage -c 127.0.0.1:8091 -u admin -p p@ssw0rd --set --rbac-username admin2 --rbac-password p@ssw0rd \
 --rbac-name "admin2" --roles bucket_full_access[*],admin --auth-domain local


create_bucket()
{
  BUCKET_NAME=test
  echo "Adding bucket: $BUCKET_NAME ..."

  #create bucket
  couchbase-cli bucket-create --cluster couchbase://127.0.0.1 -u admin -p p@ssw0rd \
    --bucket $BUCKET_NAME --bucket-type couchbase --bucket-ramsize 200 --bucket-replica 1

  #Create primary index
  /opt/couchbase/bin/cbq -u admin -p p@ssw0rd -e http://127.0.0.1:8093 --script="CREATE PRIMARY INDEX \`#primary\` ON $BUCKET_NAME USING GSI"

  couchbase-cli user-manage --cluster couchbase://127.0.0.1 -u admin -p p@ssw0rd \
    --set --rbac-username admin --rbac-password p@ssw0rd --roles "Admin" --auth-domain local
}

echo "Health Script creation..."

cat << EOF > /health-scripts/couchbase-health.sh
#!/bin/bash

set -e
cbq --script="select * from admin use keys[\"setup_version\"]" -p ${PASSWORD} -u ${USER} | grep -q "\"setup_version\": 1"

EOF

chmod +x /health-scripts/couchbase-health.sh

echo "Create bucket"
create_bucket

echo "Configuration completed!"

fg 1