#! /bin/bash

export DEEPDIVE_HOME=`cd $(dirname $0)/../..; pwd`
export APP_HOME=`pwd`

# Machine Configuration
export MEMORY="4g"
export PARALLELISM=4

# Database Configuration
export DBNAME=deepdive_multinomial_example
export PGUSER=${PGUSER:-`whoami`}
export PGPASSWORD=${PGPASSWORD:-}
export PGPORT=${PGPORT:-5432}
export PGHOST=${PGHOST:-localhost}

# SBT Options
export SBT_OPTS="-Xmx$MEMORY"