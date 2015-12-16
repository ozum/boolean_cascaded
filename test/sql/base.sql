\set ECHO 0
BEGIN;
\i sql/boolean_cascaded.sql
\set ECHO all

-- You should write your tests

SELECT boolean_cascaded('foo', 'bar');

SELECT 'foo' #? 'bar' AS arrowop;

CREATE TABLE ab (
    a_field boolean_cascaded
);

INSERT INTO ab VALUES('foo' #? 'bar');
SELECT (a_field).a, (a_field).b FROM ab;

SELECT (boolean_cascaded('foo', 'bar')).a;
SELECT (boolean_cascaded('foo', 'bar')).b;

SELECT ('foo' #? 'bar').a;
SELECT ('foo' #? 'bar').b;

ROLLBACK;
