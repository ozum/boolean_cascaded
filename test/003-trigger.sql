\i sql/base.sql;

BEGIN;
SELECT plan(3);

INSERT INTO "Category" ("id", "parentId", "isActive") VALUES
	(1, NULL, FALSE),
	(2, NULL, TRUE),
	(3, 1, TRUE),
	(4, 3, FALSE);

SELECT results_eq('SELECT "isActive"::INTEGER FROM "Category" ORDER BY id',
    ARRAY[1, 0, 10, 11],
    'Insert');


UPDATE "Category" SET "isActive" = FALSE WHERE id = 3;

SELECT results_eq('SELECT "isActive"::INTEGER FROM "Category" ORDER BY id',
    ARRAY[1, 0, 11, 21],
    'Update to false');


UPDATE "Category" SET "isActive" = TRUE WHERE id IN (1, 4);

SELECT results_eq('SELECT "isActive"::INTEGER FROM "Category" ORDER BY id',
    ARRAY[0, 0, 1, 10],
    'Update to true');

ROLLBACK;