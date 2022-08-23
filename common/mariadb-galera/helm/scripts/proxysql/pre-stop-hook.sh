#!/usr/bin/env bash
set +e
set -u
set -o pipefail

source ${BASE}/bin/common-functions.sh

function checkgaleralocalstate {
  mysql --defaults-file=${BASE}/etc/my.cnf --protocol=tcp --user=root --host=localhost --port=${MYSQL_PORT} --database=mysql --connect-timeout={{ $.Values.livenessProbe.timeoutSeconds.application }} --execute="SHOW GLOBAL STATUS LIKE 'wsrep_local_state_comment';" --batch --skip-column-names | grep --silent 'Synced'
  if [ $? -eq 0 ]; then
    loginfo "${FUNCNAME[0]}" 'MariaDB Galera node in sync with the cluster'
  else
    logerror "${FUNCNAME[0]}" 'MariaDB Galera node not synced with the cluster'
    exit 1
  fi
}

function checkgaleraclusterstate {
  mysql --defaults-file=${BASE}/etc/my.cnf --protocol=tcp --user=root --host=localhost --port=${MYSQL_PORT} --database=mysql --connect-timeout={{ $.Values.livenessProbe.timeoutSeconds.application }} --execute="SHOW GLOBAL STATUS LIKE 'wsrep_cluster_status';" --batch --skip-column-names | grep --silent 'Primary'
  if [ $? -eq 0 ]; then
    loginfo "${FUNCNAME[0]}" 'MariaDB Galera node reports a working cluster status'
  else
    logerror "${FUNCNAME[0]}" 'MariaDB Galera node reports a not working cluster status'
    exit 1
  fi
}

function checkgaleranodeconnected {
  mysql --defaults-file=${BASE}/etc/my.cnf --protocol=tcp --user=root --host=localhost --port=${MYSQL_PORT} --database=mysql --connect-timeout={{ $.Values.livenessProbe.timeoutSeconds.application }} --execute="SHOW GLOBAL STATUS LIKE 'wsrep_connected';" --batch --skip-column-names | grep --silent 'ON'
  if [ $? -eq 0 ]; then
    loginfo "${FUNCNAME[0]}" 'MariaDB Galera node connected to other cluster nodes'
  else
    logerror "${FUNCNAME[0]}" 'MariaDB Galera node not connected to other cluster nodes'
    exit 1
  fi
}

function shutdowngaleranode {
  mysql --defaults-file=${BASE}/etc/my.cnf --protocol=tcp --user=root --host=localhost --port=${MYSQL_PORT} --database=mysql --connect-timeout={{ $.Values.livenessProbe.timeoutSeconds.application }} --execute="SHUTDOWN WAIT FOR ALL SLAVES;"
  if [ $? -eq 0 ]; then
    loginfo "${FUNCNAME[0]}" 'MariaDB Galera node shutdown successful'
  else
    logerror "${FUNCNAME[0]}" 'MariaDB Galera node shutdown failed'
    exit 1
  fi
}

function rejectnewconnectionstogaleranode {
  mysql --defaults-file=${BASE}/etc/my.cnf --protocol=tcp --user=root --host=localhost --port=${MYSQL_PORT} --database=mysql --connect-timeout={{ $.Values.livenessProbe.timeoutSeconds.application }} --execute="SET GLOBAL wsrep_reject_queries=ALL;"
  if [ $? -eq 0 ]; then
    loginfo "${FUNCNAME[0]}" 'MariaDB Galera node successfully configured to reject new connections'
  else
    logerror "${FUNCNAME[0]}" 'MariaDB Galera node configuration failed to reject new connections'
    exit 1
  fi
}

loginfo "null" "preStop hook started"
checkgaleraclusterstate
checkgaleranodeconnected
checkgaleralocalstate
rejectnewconnectionstogaleranode
setconfigmap "seqno" "" "Reset"
setconfigmap "primary" "" "Reset"
setconfigmap "running" "" "Reset"
loginfo "null" "preStop hook done"
