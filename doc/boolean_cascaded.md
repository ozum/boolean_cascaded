boolean_cascaded
================

Synopsis
--------

  See Usage

Description
-----------

PostgreSQL Extension of data type, trigger and operators to store cascaded status for parent-children records.

Usage
-----

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

Support
-------

  [Issue Tracker](https://github.com/ozum/boolean_cascaded/issues)

Author
------

Özüm Eldoğan

Copyright and License
---------------------

Copyright (c) 2015 Özüm Eldoğan.

