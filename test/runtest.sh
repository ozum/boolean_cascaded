#! /usr/bin/env bash

# NOTE: Test requires pgtap PostgreSQL test extension and pg_prove Perl module
# sudo cpan TAP::Parser::SourceHandler::pgTAP
# CREATE EXTENSION pgtap
# Get file dir
file_dir=$( cd "$(dirname "${BASH_SOURCE}")" ; pwd -P );

# Set env var to look db credentials, hide notice messages.
export PGOPTIONS='--client-min-messages=warning'
export PGUSER=user
export PGPASSWORD=password

db="boolean-cascaded-test-5291";

# Create test db
createdb -h 127.0.0.1 -U user --no-password $db;

psql -f $file_dir/sql/extension.sql -U user -d $db --no-password --echo-errors -q;
psql -f $file_dir/sql/create-db.sql -U user -d $db --no-password --echo-errors -q;
psql -f $file_dir/sql/create-test-objects.sql -U user -d $db --no-password --echo-errors -q;

# Test DB
#psql -d $db -Xf $file_dir/*.sql;
pg_prove -d $db -U user $file_dir/*.sql;
#pg_prove -d $db -U user $file_dir/002-cache_recursive.sql;
#pg_prove -d $db -U user $file_dir/002c-cache_recursive.sql;
#psql -f $file_dir/utility/data_bulk.sql -U user -d $db --no-password --echo-errors -q;

dropdb -h 127.0.0.1 -U user --no-password $db;
