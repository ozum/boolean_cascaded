CREATE EXTENSION IF NOT EXISTS hstore; -- WITH SCHEMA;
CREATE TYPE boolean_cascaded;

CREATE OR REPLACE FUNCTION boolcasin (pg_catalog.cstring)
RETURNS boolean_cascaded AS 'int4in' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

CREATE OR REPLACE FUNCTION boolcasout (boolean_cascaded)
RETURNS pg_catalog.cstring AS 'int4out' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

CREATE OR REPLACE FUNCTION boolcasrecv (pg_catalog.internal)
RETURNS boolean_cascaded AS 'int4recv' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

CREATE OR REPLACE FUNCTION boolcassend (boolean_cascaded)
RETURNS bytea AS 'int4send' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

CREATE TYPE boolean_cascaded (
 LIKE = int4,
 INPUT = boolcasin,
 OUTPUT = boolcasout,
 RECEIVE = boolcasrecv,
 SEND = boolcassend
);

COMMENT ON TYPE public.boolean_cascaded
IS 'Integer temelli bir tiptir. Kendi ile birlikte gelen trigger ile kullanılmak
üzere dizayn edilmiştir. Bunun dışında genel kullanıma uygun değildir.

Kendisine ait false değerini ve kaydın parent''larından gelen FALSE değerlerinin
toplamını tutan veri türü.

Birler basamağı dışındaki basamaklardaki sayı parent''lardan kaç adet false
cascade edildiğini tutar.
Birler basamağı 1 veya 0 olabilir ve kaydın kendisinin false adedini tutar. Yani
1 false, 0 true olur.

Örnekler:
1: Kendisi false, çünkü birler basamağı 1. Parent''lardan false cascade edilmemiş.
20: Kendisi false değil (true), çünkü birler basamağı 0, parent''lardan 2 adet
    false cascade edilmiş.
41: Kendisi false, birler basamağı basamağı 1. Parent''lardan 4 adet false
    cascade edilmiş.


Conversion Kuralları:
To Boolean: 0 olmayan tüm değerler FALSE olarak convert edilir. 0 değeri TRUE
olarak convert edilir.

From Boolean: Boolean''dan dönüştürülürken, TRUE: -1, FALSE: -2 olarak convert
edilir. Bunun sebebi bir SQL''de bu alan TRUE veya FALSE olarak set edilirse
TRIGGER''ın bunu otomatik cascade güncellemelerden ayırabilmesi ve önceden mevcut
cascaded değerleri koruyabilmesi içindir.
';

/*************************************************************************
						  CONVERSION FUNCTIONS
**************************************************************************/
CREATE OR REPLACE FUNCTION public.boolean (
  boolean_cascaded
)
RETURNS boolean AS'
DECLARE
	input ALIAS FOR $1;
BEGIN
	RETURN input IN (0, -1);
END;
'LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 2;

CREATE OR REPLACE FUNCTION public.boolcas (
  boolean
)
RETURNS public.boolean_cascaded AS'
DECLARE
	input ALIAS FOR $1;
BEGIN
    IF (input) THEN
        RETURN -1;	-- TRUE
	ELSE
    	RETURN -2;  -- FALSE
    END IF;
END;
'LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 2;

-- CREATE OR REPLACE FUNCTION public.boolean_cascaded (
--   smallint
-- )
-- RETURNS integer AS'int2_integer'LANGUAGE 'internal'
-- IMMUTABLE
-- RETURNS NULL ON NULL INPUT
-- SECURITY INVOKER
-- COST 1;

-- CREATE OR REPLACE FUNCTION public.boolean_cascaded (
--   bigint
-- )
-- RETURNS integer AS'int8_integer'LANGUAGE 'internal'
-- IMMUTABLE
-- RETURNS NULL ON NULL INPUT
-- SECURITY INVOKER
-- COST 1;
-- 
-- COMMENT ON FUNCTION public.boolean_cascaded(bigint)
-- IS 'convert int8 to boolean_cascaded';
-- 
-- COMMENT ON FUNCTION public.boolean_cascaded(smallint)
-- IS 'convert int2 to boolean_cascaded';
-- 
-- CREATE OR REPLACE FUNCTION public.boolean_cascaded (
--   integer
-- )
-- RETURNS integer AS'int4_integer'LANGUAGE 'internal'
-- IMMUTABLE
-- RETURNS NULL ON NULL INPUT
-- SECURITY INVOKER
-- COST 1;
-- 
-- COMMENT ON FUNCTION public.boolean_cascaded(integer)
-- IS 'convert int4 to boolean_cascaded';



/*************************************************************************
						  OPERATOR FUNCTIONS
**************************************************************************/

-- boolean_cascaded 
-- ----------------

CREATE OR REPLACE FUNCTION boolcas_eq (
  boolean_cascaded,
  boolean_cascaded
)
RETURNS boolean AS 'int4eq' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

COMMENT ON FUNCTION boolcas_eq(boolean_cascaded, boolean_cascaded)
IS 'implementation of = operator';


CREATE OR REPLACE FUNCTION boolcas_ne (
  boolean_cascaded,
  boolean_cascaded
)
RETURNS boolean AS 'int4ne' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

COMMENT ON FUNCTION boolcas_eq(boolean_cascaded, boolean_cascaded)
IS 'implementation of = operator';




-- INTEGER 
-- -------

CREATE OR REPLACE FUNCTION boolcas_eq (
  boolean_cascaded,
  integer
)
RETURNS boolean AS 'int4eq' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

COMMENT ON FUNCTION boolcas_eq(boolean_cascaded, integer)
IS 'implementation of = operator';

CREATE OR REPLACE FUNCTION boolcas_eq (
  integer,
  boolean_cascaded
)
RETURNS boolean AS 'int4eq' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

COMMENT ON FUNCTION boolcas_eq(integer, boolean_cascaded)
IS 'implementation of = operator';

CREATE OR REPLACE FUNCTION boolcas_ne (
  boolean_cascaded,
  integer
)
RETURNS boolean AS 'int4ne' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

COMMENT ON FUNCTION boolcas_ne(boolean_cascaded, integer)
IS 'implementation of <> operator';

CREATE OR REPLACE FUNCTION boolcas_ne (
  integer,
  boolean_cascaded
)
RETURNS boolean AS 'int4ne' LANGUAGE 'internal'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 1;

COMMENT ON FUNCTION boolcas_eq(integer, boolean_cascaded)
IS 'implementation of = operator';



-- BOOLEAN 
-- -------

CREATE OR REPLACE FUNCTION boolcas_eq (
  boolean_cascaded,
  boolean
)
RETURNS boolean AS
$body$
DECLARE
    
BEGIN
	RETURN $1::boolean = $2;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 10;

COMMENT ON FUNCTION boolcas_eq(boolean_cascaded, boolean)
IS 'implementation of = operator';



CREATE OR REPLACE FUNCTION boolcas_eq (
  boolean,
  boolean_cascaded
)
RETURNS boolean AS
$body$
DECLARE
    
BEGIN
	RETURN $1 = $2::boolean;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 10;

COMMENT ON FUNCTION boolcas_eq(boolean, boolean_cascaded)
IS 'implementation of = operator';


CREATE OR REPLACE FUNCTION boolcas_ne (
  boolean_cascaded,
  boolean
)
RETURNS boolean AS
$body$
DECLARE
    
BEGIN
	RETURN $1::boolean <> $2;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 10;

COMMENT ON FUNCTION boolcas_eq(boolean_cascaded, boolean)
IS 'implementation of <> operator';


CREATE OR REPLACE FUNCTION boolcas_ne (
  boolean,
  boolean_cascaded
)
RETURNS boolean AS
$body$
DECLARE
    
BEGIN
	RETURN $1 <> $2::boolean;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 10;

COMMENT ON FUNCTION boolcas_eq(boolean, boolean_cascaded)
IS 'implementation of <> operator';

CREATE CAST (boolean_cascaded AS integer) WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (boolean_cascaded AS BOOLEAN) WITH FUNCTION "boolean"(public.boolean_cascaded) AS IMPLICIT;

CREATE CAST (integer AS boolean_cascaded) WITHOUT FUNCTION AS IMPLICIT;
CREATE CAST (BOOLEAN AS boolean_cascaded) WITH FUNCTION boolcas(boolean) AS IMPLICIT;
-- CREATE CAST (bigint AS boolean_cascaded) WITH function boolean_cascaded(bigint) AS IMPLICIT;
-- CREATE CAST (smallint AS boolean_cascaded) WITH function boolean_cascaded(smallint) AS IMPLICIT;

CREATE OPERATOR public.= (LEFTARG = public.boolean_cascaded, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>) ,PROCEDURE = boolcas_eq, HASHES);
CREATE OPERATOR public.<> (LEFTARG = public.boolean_cascaded, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = boolcas_ne);
CREATE OPERATOR public.= (LEFTARG = public.boolean_cascaded, RIGHTARG = INTEGER, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>) ,PROCEDURE = boolcas_eq, HASHES);
CREATE OPERATOR public.<> (LEFTARG = public.boolean_cascaded, RIGHTARG = INTEGER, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = boolcas_ne);
CREATE OPERATOR public.= (LEFTARG = INTEGER, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>) ,PROCEDURE = boolcas_eq, HASHES);
CREATE OPERATOR public.<> (LEFTARG = INTEGER, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = boolcas_ne);
CREATE OPERATOR public.= (LEFTARG = public.boolean_cascaded, RIGHTARG = boolean, COMMUTATOR = OPERATOR(public.=), NEGATOR = OPERATOR(public.<>) ,PROCEDURE = boolcas_eq, HASHES);
CREATE OPERATOR public.<> (LEFTARG = boolean, RIGHTARG = public.boolean_cascaded, COMMUTATOR = OPERATOR(public.<>), NEGATOR = OPERATOR(public.=) ,PROCEDURE = boolcas_ne);

/*************************************************************************
						  UTILITY FUNCTIONS
**************************************************************************/


CREATE OR REPLACE FUNCTION public.boolcas_fk_name (
  p_table text,
  p_referenced_table text,
  p_camel_case boolean
)
RETURNS text AS
$body$
DECLARE
    v_fk_prefix TEXT := CASE WHEN p_table = p_referenced_table THEN 'parent' ELSE p_referenced_table END;
BEGIN
	IF p_camel_case IS NULL THEN
    	p_camel_case := LEFT(p_table, 1) = UPPER(LEFT(p_table, 1));		-- Tablonun baş harfi büyük ise camelCase olduğunu varsay.
    END IF;

    RETURN CASE WHEN p_camel_case THEN lower(left(v_fk_prefix, 1)) || right(v_fk_prefix, -1) || 'Id' ELSE v_fk_prefix || '_id' END;
END;
$body$
LANGUAGE 'plpgsql'
IMMUTABLE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 10;

COMMENT ON FUNCTION public.boolcas_fk_name(p_table text, p_referenced_table text, p_camel_case boolean)
IS 'boolcas_fk(TEXT table, TEXT p_referenced_table, BOOLEAN camel_case)

Verilen parametrelere göre foreign key için isim oluşturur.

Tablo ismi ile referans verilen tablo ismi aynı ise "parentId" veya "parent_id" ismi döndürür.

Farklı ise "refereansTabloId" veya "referans_tablo_id" döndürür.


table: FK''nin bulunduğu tablonun ismi.
referenced_table: FK''in referans verdiği tablonun ismi.
camel_case: oluşturulacak FK ismi camelCase olarak mı oluşturulacak? Verilmez
			ise tablonun baş harfi büyük ise camel case olduğunu varsayar.';




/*************************************************************************
						  TRIGGER FUNCTIONS
**************************************************************************/
CREATE OR REPLACE FUNCTION public.t_boolcas_before (
)
RETURNS trigger AS
$body$
DECLARE
	v_camel 					BOOLEAN := LEFT(TG_TABLE_NAME, 1) = UPPER(LEFT(TG_TABLE_NAME, 1));		-- Tablonun baş harfi büyük ise camelCase olduğunu varsay.
    v_default_status_col		TEXT	:= CASE WHEN v_camel THEN 'isActive' ELSE 'is_active' END;		-- Varsayılan alan adı.
    p_parent_tables_and_cols  	TEXT[]  := TG_ARGV[0]::TEXT[];                                         	-- Array of arrays: Parent tablo, FK, PK. PK Default: tabloAdıId veya parentId, PK Default: id. Ör: ARRAY[['company', 'company_id', 'id'],['project', 'id', 'project_id'], ['color']]
    p_status_col                TEXT    := COALESCE(NULLIF(TG_ARGV[1], ''), v_default_status_col);  	-- Statüyü tutan alanın ismi. Default: 'is_active' veya 'isActive'.
    v_new						INTEGER;
    v_old						INTEGER := 0;
    v_parent_changed			BOOLEAN	:= FALSE;														-- Parent alanlardan biri değişti mi?
    v_table_and_col             TEXT[];                                                               	-- Döngüde kullanılacak
    v_parent_table				TEXT;																	-- Döngüde kullanılacak
    v_pk_col					TEXT;																	-- Döngüde kullanılacak
    v_fk_col					TEXT;																	-- Döngüde kullanılacak
	v_fk						INTEGER;
    v_pk						INTEGER;
    v_delta						INTEGER := 0;
	v_result					INTEGER := 0;
BEGIN
	RAISE NOTICE 'TRIGGER (%): %, %.id: %', TG_NAME, TG_OP, TG_TABLE_NAME, NEW.id;

    IF TG_OP = 'UPDATE' THEN
    	EXECUTE FORMAT('SELECT $1.%I, $2.%1$I', p_status_col) INTO v_old, v_new USING OLD, NEW;
    ELSIF TG_OP = 'INSERT' THEN
    	EXECUTE FORMAT('SELECT $1.%I', p_status_col) INTO v_new USING NEW;
    END IF;



    IF p_parent_tables_and_cols IS NOT NULL AND TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'CP 1';
        --EXECUTE FORMAT('SELECT $1.%I, $2.%1$I', p_status_col) INTO v_old, v_new USING OLD, NEW;
        FOREACH v_table_and_col SLICE 1 IN ARRAY p_parent_tables_and_cols LOOP
            v_parent_table := v_table_and_col[1];
            v_fk_col := COALESCE(v_table_and_col[2], boolcas_fk_name(TG_TABLE_NAME, v_parent_table, v_camel));
            --RAISE EXCEPTION 'IS CHANGED: %, %, %, %', OLD."parentId", NEW."parentId", OLD."categoryId", NEW."categoryId";-- v_fk_col;--FORMAT('SELECT v_parent_changed OR OLD.%1$I IS DISTINCT FROM NEW.%1$I', v_fk_col);
         EXECUTE FORMAT('SELECT $1 OR $2.%1$I IS DISTINCT FROM $3.%1$I', v_fk_col) INTO v_parent_changed USING v_parent_changed, OLD, NEW;
        END LOOP;
    END IF;

--RAISE EXCEPTION 'Parent Changed: %', v_parent_changed;

	IF v_parent_changed OR TG_OP = 'INSERT' THEN	-- UPDATE with parent change OR INSERT
        RAISE NOTICE 'CP 2a';
        --EXECUTE FORMAT('SELECT $1.%I', p_status_col) INTO v_new USING NEW;

        IF TG_OP = 'INSERT' AND v_new > 1 THEN RAISE EXCEPTION '"%" column accepts Boolean values.', p_status_col; END IF;

		IF p_parent_tables_and_cols IS NOT NULL THEN
            FOREACH v_table_and_col SLICE 1 IN ARRAY p_parent_tables_and_cols LOOP
                v_parent_table := v_table_and_col[1];
                v_fk_col       := COALESCE(v_table_and_col[2], boolcas_fk_name(TG_TABLE_NAME, v_parent_table, v_camel));
                v_pk_col       := COALESCE(v_table_and_col[3], 'id');
                EXECUTE FORMAT('SELECT $1.%I, $1.%I', v_fk_col, v_pk_col) INTO v_fk, v_pk USING NEW;

                IF (TG_TABLE_NAME = v_parent_table AND v_fk = v_pk) THEN
                    RAISE EXCEPTION 'boolean_cascaded reference error in %(). Column references itself.', TG_NAME;
                END IF;

                IF v_fk IS NOT NULL THEN
                    EXECUTE FORMAT('SELECT %I FROM %I WHERE %I = $1', p_status_col, v_parent_table, v_pk_col) INTO v_delta USING v_fk;
                    v_result := v_result + ((v_delta / 10) + (v_delta % 10)) * 10;
                    IF v_result > 990 THEN
                        RAISE EXCEPTION 'boolean_cascaded stack overflow in %(). Perhaps you have a circular reference.', TG_NAME;
                    END IF;
                END IF;
                RAISE NOTICE 'Parent Total: %', v_result;
            END LOOP;
        END IF;

 		RAISE NOTICE 'A0. OLD: %, NEW: %, RESULT: %', v_old, v_new, v_result;
        IF v_new = -2 THEN -- FALSE
        	v_result := v_result + 1;
        ELSIF v_new >= 0 OR v_new IS NULL THEN
        	v_result := v_result + v_old % 10;	-- Insert veya parent değişiminde eski parent değerlerini görmezden gel ve sadece birler basamağını kullan (kendi değeri)
        END IF;

    --ELSIF v_new 	-- Parent değişmeyen update işlemi ise
        -- Yeni değer -1 (TRUE) veya -2 (FALSE) geldiyse
    ELSIF v_new < 0 THEN
            RAISE NOTICE 'CP 2b';
            -- Birler basamağını yut (Integer / 10 * 10) ve yeni değeri birler basamağına yaz. Ör: False ise 20'yi 21 yap.
            v_result := CASE v_new WHEN -1 THEN (v_old / 10 * 10) WHEN -2 THEN (v_old / 10 * 10) + 1 END;
        --END IF;
    ELSE
        RAISE NOTICE 'CP 2c';
    	RETURN NEW;
    END IF;





    RAISE NOTICE 'A. OLD: %, NEW: %, RESULT: %', v_old, v_new, v_result;

    -- Yeni değer -1 (TRUE) veya -2 (FALSE) geldiyse
    --IF v_new < 0 THEN
      --  RAISE NOTICE 'CP 3';
        -- Birler basamağını yut (Integer / 10 * 10) ve yeni değeri birler basamağına yaz. Ör: False ise 20'yi 21 yap.
        --v_result := CASE v_new WHEN -1 THEN (v_result / 10 * 10) WHEN -2 THEN (v_result / 10 * 10) + 1 END;
    --END IF;

    RAISE NOTICE 'B. OLD: %, NEW: %, RESULT: %', v_old, v_new, v_result;
     RAISE NOTICE 'C: NEW: %', NEW."isActive";

    IF v_new IS DISTINCT FROM v_result THEN
    	RAISE NOTICE 'CP 3';
        -- Yeni değeri ROW'a ata.
        IF p_status_col = 'xisActive' THEN
        	NEW."isActive" := v_result;
		ELSIF p_status_col = 'xis_active' THEN
        	NEW.is_active := v_result;
        ELSE

            RAISE NOTICE '% ID: %, %, %', TG_TABLE_NAME, NEW.id, v_new, format('%I=>%s', p_status_col, v_result);
        	--IF v_result IS NOT NULL THEN
                NEW := NEW #= format('%I=>%s', p_status_col, v_result)::hstore;
            --END IF;
        END IF;
    END IF;

    RAISE NOTICE 'D: NEW: %', NEW."isActive";

    RETURN NEW;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;

COMMENT ON FUNCTION public.t_boolcas_before()
IS 't_boolean_cascaded_before(column_name)

Column name boolean_cascaded veri tipinde veri tutan alanın ismidir.

Default ''isActive'' veya ''is_active'' (Tablo adının baş harfinin büyük küçük
olmasına göre)

boolean_cascaded veri tipinde -1 (TRUE) veya -2 (FALSE) değeri set edildiyse
cascade edilmiş değerlere dokunmadan ilgili alanı güncelleyen trigger.

Before Each Row olarak çağrılmalı ve condition olarak ilgili alanın güncellenmesi
ve yeni değerinin 0''dan küçük olması verilmeli.

Örnek:

CREATE TRIGGER "ItemCategoryTrigger"
  BEFORE UPDATE OF "isActive"
  ON "ItemCategory" FOR EACH ROW
  WHEN (new."isActive" < 0)
EXECUTE PROCEDURE t_boolean_cascaded_before();';







CREATE OR REPLACE FUNCTION public.t_boolcas_children_after (
)
RETURNS trigger AS
$body$
DECLARE
    v_camel						BOOLEAN := LEFT(TG_TABLE_NAME, 1) = UPPER(LEFT(TG_TABLE_NAME, 1));		-- Tablonun baş harfi büyük ise camelCase olduğunu varsay.
    v_default_status_col		TEXT	:= CASE WHEN v_camel THEN 'isActive' ELSE 'is_active' END;		-- Varsayılan alan adı.
    p_children_tables_and_cols  TEXT[]  := TG_ARGV[0]::TEXT[];                                          -- Array of arrays: Child Tablo, FK. Ör: ARRAY[['contact','company_id'],['project','company_id']]
    p_id_col                    TEXT    := COALESCE(NULLIF(TG_ARGV[1], ''), 'id');                 		-- Parent tabloda kaydın ID'sini tutan sütunun ismi. Default 'id'.
    p_status_col                TEXT    := COALESCE(NULLIF(TG_ARGV[2], ''), v_default_status_col);  	-- Statüyü tutan alanın ismi. Default: 'is_active' veya 'isActive'.

    v_table_and_col             TEXT[];                                                               	-- Döngüde kullanılacak
    v_child_table				TEXT;																	-- Döngüde kullanılacak
    v_fk_col					TEXT;																	-- Döngüde kullanılacak
    v_delta                     INTEGER;                                                               	-- Alt kayıtlar için statüde oluşan değişim miktarı.
    v_new						INTEGER;
    v_old						INTEGER;										
BEGIN
	EXECUTE FORMAT('SELECT $1.%I, $2.%1$I', p_status_col) INTO v_old, v_new USING OLD, NEW;
	-- Count:      Kendi  +  Parent'tan gelen  - Kendi	-  Parent'dan gelen
	v_delta = ((v_new % 10) + (v_new / 10) - (v_old % 10) - (v_old / 10)) * 10;
    --RAISE EXCEPTION '%, %', v_old, v_new;
    IF v_delta > 990 THEN
    	RAISE EXCEPTION 'boolean_cascaded stack overflow in %. Perhaps you have a circular reference.', TG_NAME;
    END IF;
RAISE NOTICE '%, ID: %, OLD: %, NEW: %, Delta:%', TG_TABLE_NAME, NEW.id, v_old, v_new, v_delta;
    -- Her bir alt tablodaki ilgili alanın değerini güncelle.
    FOREACH v_table_and_col SLICE 1 IN ARRAY p_children_tables_and_cols LOOP
        RAISE NOTICE 'ID: %, Child Table: %', NEW.id, v_table_and_col[1];
        v_child_table := v_table_and_col[1];
		v_fk_col	  := COALESCE(v_table_and_col[2], boolcas_fk_name(v_child_table, TG_TABLE_NAME, v_camel));
        
        -- Aşağıdaki sorgu: UPDATE contact SET is_active = is_active + v_delta WHERE company_id = NEW.id
        --RAISE NOTICE '%', FORMAT('UPDATE %I SET %2$I = %2$I + $1 WHERE %I = $2.%I (%s)', v_child_table, p_status_col, v_fk_col, p_id_col, NEW.id);
        EXECUTE FORMAT('UPDATE %I SET %2$I = %2$I + $1 WHERE %I = $2.%I', v_child_table, p_status_col, v_fk_col, p_id_col) USING v_delta, NEW;
    END LOOP;

    RETURN NEW;
END
$body$
LANGUAGE 'plpgsql'
VOLATILE
RETURNS NULL ON NULL INPUT
SECURITY INVOKER
COST 100;

