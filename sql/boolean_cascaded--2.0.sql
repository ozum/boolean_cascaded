/*
 * Author: Özüm Eldoğan
 * Created at: 2015-12-16 12:25:11 +0200
 *
 */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION boolean_cascaded" to load this file. \quit

CREATE TYPE public.boolean_cascaded AS (
  status BOOLEAN,                   -- Stores status of itself
  cascaded_false_count SMALLINT     -- Stores count of false values cascaded.
);

--SET LOCAL search_path TO @extschema@, public;
CREATE OR REPLACE FUNCTION boolean_cascaded_add (
  p_left public.boolean_cascaded,
  p_right INTEGER
)
RETURNS public.boolean_cascaded AS
$body$
BEGIN
    p_left.cascaded_false_count := p_left.cascaded_false_count + p_right;
    RETURN p_left;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION boolean_cascaded_add (
  p_left INTEGER,
  p_right public.boolean_cascaded
)
RETURNS public.boolean_cascaded AS
$body$
BEGIN
    p_right.cascaded_false_count := p_left + p_right.cascaded_false_count;
    RETURN p_right;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


-- Subtracts given value from cascaded_false_count.
CREATE OR REPLACE FUNCTION boolean_cascaded_subtract (
  p_left public.boolean_cascaded,
  p_right INTEGER
)
RETURNS public.boolean_cascaded AS
$body$
BEGIN
    p_left.cascaded_false_count := p_left.cascaded_false_count - p_right;
    RETURN p_left;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


-- Subtracts cascaded_false_count from given integer.
CREATE OR REPLACE FUNCTION boolean_cascaded_subtract (
  p_left INTEGER,
  p_right public.boolean_cascaded
)
RETURNS public.boolean_cascaded AS
$body$
BEGIN
    p_right.cascaded_false_count := p_left - p_right.cascaded_false_count;
    RETURN p_right;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


-- Casts boolean_cascaded to boolean. Returns true if status is true and cascaded_false_count is zero.
CREATE OR REPLACE FUNCTION boolean_cascaded_to_bool (
  input public.boolean_cascaded
)
RETURNS boolean AS
$body$
BEGIN
    RETURN (input.status = true AND input.cascaded_false_count = 0);
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


-- Casts boolean_cascaded to integer. Returns cascaded_false_count
CREATE OR REPLACE FUNCTION boolean_cascaded_to_int (
  input public.boolean_cascaded
)
RETURNS integer AS
$body$
BEGIN
    RETURN input.cascaded_false_count;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;

CREATE OR REPLACE FUNCTION boolean_cascaded_compare (
    p_left public.boolean_cascaded,
    p_right public.boolean_cascaded
)
RETURNS BOOLEAN AS
$body$
BEGIN
    RETURN (p_left.status = p_right.status AND p_left.cascaded_false_count = p_right.cascaded_false_count);
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE OR REPLACE FUNCTION boolean_cascaded_compare_not (
    p_left public.boolean_cascaded,
    p_right public.boolean_cascaded
)
RETURNS BOOLEAN AS
$body$
BEGIN
    RETURN (p_left.status <> p_right.status OR p_left.cascaded_false_count <> p_right.cascaded_false_count);
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT;


CREATE FUNCTION t_boolean_cascaded_update()
RETURNS TRIGGER
 LANGUAGE plpgsql
 VOLATILE
AS
$$
DECLARE
    p_children_tables_and_cols  TEXT[]  = TG_ARGV[0]::TEXT[];                                           -- Array of arrays: Child tabloların ve tablolarda parent id'yi tutan sütunların listesi. Ör: ARRAY[['contact','company_id'],['project','company_id']]
    p_id_col                    TEXT    = COALESCE(TG_ARGV[1]::TEXT,    'id');                          -- Parent tabloda kaydın ID'sini tutan sütunun ismi. Default 'id'.
    p_status_col                TEXT    = COALESCE(TG_ARGV[2]::TEXT,    'is_active');                   -- Statüyü tutan alanın ismi. Default: 'is_active'

    v_table_and_col             TEXT[];                                                                 -- Döngüde kullanılacak
    v_delta                     INTEGER;                                                                -- Alt kayıtlar için statüde oluşan değişim miktarı.
BEGIN

    -- p_status_col: Kendi statüsü (true, false), p_status_parent_col: Parent'lardan gelen true count'u (Perl Ref count gibi. Her parent'ın true yapılması alttakilere 1 ekler.)
    -- Aşağıdaki sorgu: v_delta = CASE WHEN NEW.is_active.status THEN 0 ELSE 1 + NEW.is_active.cascaded_false_count - CASE WHEN OLD.is_active.status THEN 0 ELSE 1 END - OLD.is_active.cascaded_false_count;
    EXECUTE 'SELECT CASE WHEN $1.' || quote_ident(p_status_col) || '.status THEN 0 ELSE 1 END + $1.' || quote_ident(p_status_col) || '.cascaded_false_count - CASE WHEN $2.' || quote_ident(p_status_col) || '.status THEN 0 ELSE 1 END - $2.' || quote_ident(p_status_col) || '.cascaded_false_count'
        INTO v_delta USING NEW, OLD;

    -- Her bir alt tablodaki ilgili alanın değerini güncelle.
    FOREACH v_table_and_col SLICE 1 IN ARRAY p_children_tables_and_cols LOOP
        -- Aşağıdaki sorgu: UPDATE contact SET is_active_parent_count = is_active_parent_count + v_delta WHERE company_id = NEW.id
        EXECUTE 'UPDATE ' || quote_ident(v_table_and_col[1]) || ' SET ' || quote_ident(p_status_col) || ' = ' || quote_ident(p_status_col) || ' + $1 WHERE '
            || quote_ident( v_table_and_col[2] ) || ' = $2.' || quote_ident(p_id_col) USING v_delta, NEW;
    END LOOP;

    RETURN NEW;
END
$$
;

-- Create operators and casts.
CREATE CAST (public.boolean_cascaded AS BOOLEAN) WITH function boolean_cascaded_to_bool(public.boolean_cascaded) AS IMPLICIT;
CREATE CAST (public.boolean_cascaded AS INTEGER) WITH function boolean_cascaded_to_int(public.boolean_cascaded) AS IMPLICIT;
CREATE OPERATOR public.= (LEFTARG = public.boolean_cascaded, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>) ,PROCEDURE = boolean_cascaded_compare);
CREATE OPERATOR public.<> (LEFTARG = public.boolean_cascaded, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = boolean_cascaded_compare_not);
CREATE OPERATOR public.+ (LEFTARG = public.boolean_cascaded, RIGHTARG = INTEGER, COMMUTATOR = OPERATOR(public.+),PROCEDURE = boolean_cascaded_add);
CREATE OPERATOR public.+ (LEFTARG = INTEGER, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.+),PROCEDURE = boolean_cascaded_add);
CREATE OPERATOR public.- (LEFTARG = public.boolean_cascaded, RIGHTARG = INTEGER, PROCEDURE = boolean_cascaded_subtract);
CREATE OPERATOR public.- (LEFTARG = INTEGER, RIGHTARG = public.boolean_cascaded, PROCEDURE = boolean_cascaded_subtract);
