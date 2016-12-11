\i sql/base.sql;

BEGIN;
SELECT plan(10);

SELECT is(0::boolean_cascaded::integer, 0, 'boolean_cascaded 0 to Integer');
SELECT is(1::boolean_cascaded::integer, 1, 'boolean_cascaded 1 to Integer');
SELECT is(11::boolean_cascaded::integer, 11, 'boolean_cascaded 11 to Integer');
SELECT is(0, 0::boolean_cascaded::integer, 'Integer to boolean_cascaded 0');
SELECT is(1, 1::boolean_cascaded::integer, 'Integer to boolean_cascaded 1');
SELECT is(11, 11::boolean_cascaded::integer, 'Integer to boolean_cascaded 11');

SELECT is(TRUE::boolean_cascaded::integer, -1, 'boolean_cascaded TRUE to Integer');
SELECT is(FALSE::boolean_cascaded::integer, -2, 'boolean_cascaded FALSE to Integer');

SELECT is(TRUE::boolean_cascaded::BOOLEAN, TRUE, 'boolean_cascaded TRUE to Boolean');
SELECT is(FALSE::boolean_cascaded::BOOLEAN, FALSE, 'boolean_cascaded FALSE to Boolean');

SELECT * FROM finish();
ROLLBACK;