\i sql/base.sql;

BEGIN;
SELECT plan(12);

INSERT INTO "Color" ("id", "isActive") VALUES
	(1, TRUE),
	(2, FALSE);

SELECT results_eq('SELECT "isActive"::INTEGER FROM "Color" ORDER BY id',
    ARRAY[0, 1],
    'Insert Color');

INSERT INTO "Category" ("id", "parentId", "isActive") VALUES
	(1, NULL, FALSE),
	(2, NULL, TRUE),
	(3, 1, TRUE),
	(4, 3, FALSE);

SELECT results_eq('SELECT "isActive"::INTEGER FROM "Category" ORDER BY id',
    ARRAY[1, 0, 10, 11],
    'Insert Category');

INSERT INTO "Item" ("id", "parentId", "categoryId", "colorId", "isActive") VALUES
    (1, NULL, NULL, 1, FALSE),
    (2, NULL, NULL, 2, FALSE),
    (3, NULL, 1, 2, TRUE),
    (4, 2, 4, 2, FALSE);

SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Insert Item');


------------------------------------ UPDATE ITEM --------------------------------------
UPDATE "Item" SET "isActive" = FALSE WHERE id = 4;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Item 1');

UPDATE "Item" SET "isActive" = TRUE WHERE id = 4;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 50],
    'Update Item 2');

UPDATE "Item" SET "isActive" = FALSE WHERE id = 4;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Item 3');

UPDATE "Item" SET "isActive" = TRUE WHERE id = 2;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 10, 20, 41],
    'Update Item 4');

UPDATE "Item" SET "isActive" = FALSE WHERE id = 2;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Item 4');

------------------------------------ UPDATE CATEGORY --------------------------------------
UPDATE "Category" SET "isActive" = TRUE WHERE id = 1;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 10, 41],
    'Update Category 1');

UPDATE "Category" SET "isActive" = FALSE WHERE id = 1;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Category 2');

------------------------------------ UPDATE COLOR --------------------------------------
UPDATE "Color" SET "isActive" = TRUE WHERE id = 2;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 1, 10, 31],
    'Update Color 1');

UPDATE "Color" SET "isActive" = FALSE WHERE id = 2;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Color 1');

--PREPARE h01 AS SELECT "canCreate", "canCreateOwners" FROM "mvAppUserPrivilege" WHERE "appUserId" = 1 AND "entityId" = 1;
--PREPARE w01 AS SELECT 'organization'::"Access Level", '{}'::INTEGER[];
--SELECT results_eq('h01', 'w01', 'App User 1');

ROLLBACK;