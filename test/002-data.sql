\i sql/base.sql;

BEGIN;
SELECT plan(2);

INSERT INTO "Category" ("id", "parentId", "isActive") VALUES
	(1, NULL, FALSE),
	(2, NULL, TRUE);


SELECT results_eq('SELECT CASE WHEN "isActive" THEN TRUE ELSE FALSE END FROM "Category" ORDER BY id',
    ARRAY[FALSE, TRUE],
    'Comparison: BOOLEAN <> boolean_cascaded');

SELECT results_eq('SELECT "isActive"::boolean FROM "Category" ORDER BY id',
    ARRAY[FALSE, TRUE],
    'True should be equal 1');

ROLLBACK;