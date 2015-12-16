boolean_cascaded PostgreSQL Extension
=====================================

boolean_cascaded is custom PostgreSQL type (COMPLEX) with related operators and type casts.

It can be used to store a boolean status for parent-children records, which children's status should be set as false when parent's status set as false. See example below.

It casts to boolean easily to check status as convenient as possible.

## Installation

To build it, just do this:

    make
    make installcheck
    make install

On PostgreSQL

    CREATE EXTENSION boolean_cascaded [WITH SCHEMA extra_modules]

## Contents

### Type 

Type is installed on public schema regardless of CREATE EXTENSION schema. (Functions is installed extension schema anyway.)

  * status (BOOLEAN), (to store record's own status for preserve status during parent status changes.)
  * cascaded_false_count (SMALLINT) (to store inherited false statusses from parents.)

### Operators

| Left | Op | Right | Result | Description |
| ---- | --- | ----- | ------ | ----------- |
| boolean_cascaded | + | integer | boolean_cascaded | `result.status` = left operand's status, `result.cascaded_false_count` = left operand's cascaded_false_count + integer. |
| integer | + | boolean_cascaded | boolean_cascaded | `result.status` = right operand's status, `result.cascaded_false_count` = integer + right operand's cascaded_false_count. |
| boolean_cascaded | - | integer | boolean_cascaded | `result.status` = left operand's status, `result.cascaded_false_count` = left operand's cascaded_false_count - integer. |
| integer | - | boolean_cascaded | boolean_cascaded | `result.status` = right operand's status, `result.cascaded_false_count` = integer - right operand's cascaded_false_count. |

### Casts

`boolean_cascaded` can be cast to `boolean` or `integer`.

Boolean value equals true only status is true and `cascaded_false_count` equals zero.

| Cast Type | status | cascaded_false_count | Result |
| --- | --- | --- | --- |
| Boolean | true | 0 | true |
| Boolean | true | >0 | false |
| Boolean | false | 0 | false |
| Boolean | false | >0 | false |
| Integer | true | n | n |
| Integer | false | n | n |

### Trigger Function

#### t_boolean_cascaded_update

A trigger function named `t_boolean_cascaded_update` is created with this extension in extension schema. Paremeters of this function are: 

| Order | Type | Default | Description | Example |
| --- | --- | --- | --- | --- |
| 0 | 2 dimension Array |   | Array of arrays. Each inner array holds one child table name and foreign column name in that child table. | '{{"account", "parent_id"}, {"contact", "account_id"}}' |
| 1 | TEXT | 'id' | Primary key column name | 'id' |
| 2 | TEXT | 'is_active' | Column name which contains inherited status. | 'is_active' |  

## Example

```
account                                         contact
-------                                         --------
(PK) id         INT                         /   (PK) id          INT
(FK) parent_id  INT                --------<-   (FK) account_id  INT
is_active       boolean_cascaded            \   is_active        boolean_cascaded
```

```sql
CREATE extension boolean_cascaded WITH SCHEMA extra_modules;

CREATE TRIGGER children_status
  AFTER UPDATE OF is_active 
  ON account FOR EACH ROW 
  WHEN (OLD.is_active <> NEW.is_active)
EXECUTE PROCEDURE extra_modules.t_boolean_cascaded_update('{{"account", "parent_id"}, {"contact", "account_id"}}');
```

Some sample data:

```sql
INSERT INTO account (1, NULL, (true,0));
INSERT INTO account (2, NULL, (true,0));
INSERT INTO account (3, 1, (true,0));
INSERT INTO account (4, 3, (true,0));

INSERT INTO contact (1, 3, (true,0));
INSERT INTO contact (2, 4, (true,0));

UPDATE contact SET is_active.status = true WHERE contact.id = 1;    -- Q1: Contact #1 is NOT active now.
SELECT * FROM contact WHERE contact.id = 1 AND is_active;           -- Q2: No result
UPDATE account SET is_active.status = false WHERE account.id = 1;   -- Q3: Account #1, #3, #4, Contact #1, #2 is NOT active now.
SELECT * FROM contact WHERE is_active;                              -- Q4: No result
UPDATE account SET is_active.status = true WHERE account.id = 1;    -- Q5: Account #1, #3, #4, Contact #2 is active now. Contact #1 is still NOT active because we set it NOT active before with Q1.
UPDATE contact SET is_active.status = true WHERE contact.id = 1;    -- Q6: Contact #1 is NOT active now.
```

## Installation Methods

To build it, just do this:

    make
    make installcheck
    make install

If you encounter an error such as:

    "Makefile", line 8: Need an operator

You need to use GNU make, which may well be installed on your system as
`gmake`:

    gmake
    gmake install
    gmake installcheck

If you encounter an error such as:

    make: pg_config: Command not found

Be sure that you have `pg_config` installed and in your path. If you used a
package management system such as RPM to install PostgreSQL, be sure that the
`-devel` package is also installed. If necessary tell the build process where
to find it:

    env PG_CONFIG=/path/to/pg_config make && make installcheck && make install

And finally, if all that fails (and if you're on PostgreSQL 8.1 or lower, it
likely will), copy the entire distribution directory to the `contrib/`
subdirectory of the PostgreSQL source tree and try it there without
`pg_config`:

    env NO_PGXS=1 make && make installcheck && make install

If you encounter an error such as:

    ERROR:  must be owner of database regression

You need to run the test suite using a super user, such as the default
"postgres" super user:

    make installcheck PGUSER=postgres

Once boolean_cascaded is installed, you can add it to a database. If you're running
PostgreSQL 9.1.0 or greater, it's a simple as connecting to a database as a
super user and running:

    CREATE EXTENSION boolean_cascaded;

If you've upgraded your cluster to PostgreSQL 9.1 and already had boolean_cascaded
installed, you can upgrade it to a properly packaged extension with:

    CREATE EXTENSION boolean_cascaded FROM unpackaged;

For versions of PostgreSQL less than 9.1.0, you'll need to run the
installation script:

    psql -d mydb -f /path/to/pgsql/share/contrib/boolean_cascaded.sql

If you want to install boolean_cascaded and all of its supporting objects into a specific
schema, use the `PGOPTIONS` environment variable to specify the schema, like
so:

    PGOPTIONS=--search_path=extensions psql -d mydb -f boolean_cascaded.sql

Dependencies
------------
The `boolean_cascaded` data type has no dependencies other than PostgreSQL.

Copyright and License
---------------------

Copyright (c) 2015 Özüm Eldoğan.

