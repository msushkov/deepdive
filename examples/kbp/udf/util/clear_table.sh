#! /usr/bin/env bash

# usage: clear_table.sh <table_name>

psql -c "TRUNCATE $1 CASCADE;" deepdive_spouse