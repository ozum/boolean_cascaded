\i sql/base.sql;

BEGIN;
SELECT plan(2);

INSERT INTO "Category" ("id", "parentId", "isActive") VALUES
	(1, NULL, FALSE),
	(2, NULL, TRUE);


SELECT results_eq('SELECT CASE WHEN "isActive" THEN TRUE ELSE FALSE END FROM "Category" ORDER BY id',
	ARRAY[FALSE, TRUE],
	'Comparison: BOOLEAN <> boolean_cascaded'
);


SELECT results_eq(
	'SELECT "isActive"::boolean FROM "Category" WHERE id = 1',
	'SELECT FALSE',
	'True should be equal 1'
);

--PREPARE h01 AS SELECT "canCreate", "canCreateOwners" FROM "mvAppUserPrivilege" WHERE "appUserId" = 1 AND "entityId" = 1;
--PREPARE w01 AS SELECT 'organization'::"Access Level", '{}'::INTEGER[];
--SELECT results_eq('h01', 'w01', 'App User 1');

ROLLBACK;