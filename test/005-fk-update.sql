\i sql/base.sql;

BEGIN;
SELECT plan(15);

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


------------------------------------ UPDATE COLOR --------------------------------------
UPDATE "Color" SET "id" = 3 WHERE id = 2;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Color 1');


UPDATE "Color" SET "id" = 2 WHERE id = 3;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Color 2');


------------------------------------ UPDATE Category --------------------------------------
UPDATE "Category" SET "id" = 9 WHERE id = 1;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Category 1');

UPDATE "Category" SET "id" = 1 WHERE id = 9;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
     ARRAY[1, 11, 20, 51],
     'Update Category 2');

UPDATE "Category" SET "parentId" = NULL WHERE id = 3;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Category" ORDER BY id',
     ARRAY[1, 0, 0, 1],
     'Update Category 3a');
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 41],
    'Update Category 3b');

UPDATE "Category" SET "parentId" = 1 WHERE id = 3;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Category" ORDER BY id',
    ARRAY[1, 0, 10, 11],
     'Update Category 4a');
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
    ARRAY[1, 11, 20, 51],
    'Update Category 4b');

------------------------------------ UPDATE Item --------------------------------------
UPDATE "Item" SET "parentId" = 4 WHERE id = 3;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
     ARRAY[1, 11, 80, 51],
     'Update Item 1');

UPDATE "Item" SET "parentId" = NULL WHERE id = 3;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
     ARRAY[1, 11, 20, 51],
     'Update Item 2');

UPDATE "Item" SET "parentId" = 3 WHERE id = 4;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
     ARRAY[1, 11, 20, 51],
     'Update Item 1');

UPDATE "Item" SET "parentId" = 1 WHERE id = 4;
SELECT results_eq('SELECT "isActive"::INTEGER FROM "Item" ORDER BY id',
     ARRAY[1, 11, 20, 41],
     'Update Item 1');

ROLLBACK;