/*
Created: 9.12.2016
Modified: 11.12.2016
Project: Boolean Cascaded Test DB
Model: Boolean Cascaded Test DB
Database: PostgreSQL 9.5
*/



-- Create tables section -------------------------------------------------

-- Table Item

CREATE TABLE "Item"(
 "id" Serial NOT NULL,
 "parentId" Integer,
 "categoryId" Integer,
 "colorId" Integer,
 "isActive" "boolean_cascaded" DEFAULT 0 NOT NULL
)
;

-- Create indexes for table Item

CREATE INDEX "IX_Relationship1" ON "Item" ("parentId")
;

CREATE INDEX "IX_CategoryItems" ON "Item" ("categoryId")
;

CREATE INDEX "IX_colorItems" ON "Item" ("colorId")
;

-- Add keys for table Item

ALTER TABLE "Item" ADD CONSTRAINT "Key1" PRIMARY KEY ("id")
;

-- Create triggers for table Item

CREATE TRIGGER "boolean_cascaded_before"
  BEFORE INSERT OR UPDATE OF "isActive", "parentId", "categoryId"
  ON "Item" FOR EACH ROW
 EXECUTE PROCEDURE "t_boolcas_before"('{{Item}, {Category}, {Color}}')
;

CREATE TRIGGER "boolean_cascaded_after"
  AFTER UPDATE OF "isActive"
  ON "Item" FOR EACH ROW
 WHEN (OLD."isActive" IS DISTINCT FROM NEW."isActive")
 EXECUTE PROCEDURE "t_boolcas_children_after"('{{Item}}')
;

-- Table Category

CREATE TABLE "Category"(
 "id" Serial NOT NULL,
 "parentId" Integer,
 "isActive" "boolean_cascaded" DEFAULT 0 NOT NULL
)
;

-- Create indexes for table Category

CREATE INDEX "IX_Relationship2" ON "Category" ("parentId")
;

-- Add keys for table Category

ALTER TABLE "Category" ADD CONSTRAINT "Key2" PRIMARY KEY ("id")
;

-- Create triggers for table Category

CREATE TRIGGER "boolean_cascaded_before"
  BEFORE INSERT OR UPDATE OF "isActive", "parentId"
  ON "Category" FOR EACH ROW
 EXECUTE PROCEDURE "t_boolcas_before"('{{Category, parentId, id}}')
;

CREATE TRIGGER "boolean_cascaded_after"
  AFTER UPDATE OF "isActive"
  ON "Category" FOR EACH ROW
 WHEN (OLD."isActive" IS DISTINCT FROM NEW."isActive")
 EXECUTE PROCEDURE "t_boolcas_children_after"('{{Category, parentId}, {Item, categoryId}}')
;

-- Table Color

CREATE TABLE "Color"(
 "id" Serial NOT NULL,
 "isActive" "boolean_cascaded" DEFAULT 0 NOT NULL
)
;

-- Add keys for table Color

ALTER TABLE "Color" ADD CONSTRAINT "Key3" PRIMARY KEY ("id")
;

-- Create triggers for table Color

CREATE TRIGGER "boolean_cascaded_before"
  BEFORE INSERT OR UPDATE OF "isActive"
  ON "Color" FOR EACH ROW
 EXECUTE PROCEDURE "t_boolcas_before"()
;

CREATE TRIGGER "boolean_cascaded_after"
  AFTER UPDATE OF "isActive"
  ON "Color" FOR EACH ROW
 WHEN (OLD."isActive" IS DISTINCT FROM NEW."isActive")
 EXECUTE PROCEDURE "t_boolcas_children_after"('{{Item}}')
;

-- Create relationships section ------------------------------------------------- 

ALTER TABLE "Item" ADD CONSTRAINT "ItemChildren" FOREIGN KEY ("parentId") REFERENCES "Item" ("id") ON DELETE CASCADE ON UPDATE CASCADE
;

ALTER TABLE "Category" ADD CONSTRAINT "CategoryChildren" FOREIGN KEY ("parentId") REFERENCES "Category" ("id") ON DELETE CASCADE ON UPDATE CASCADE
;

ALTER TABLE "Item" ADD CONSTRAINT "CategoryItems" FOREIGN KEY ("categoryId") REFERENCES "Category" ("id") ON DELETE CASCADE ON UPDATE CASCADE
;

ALTER TABLE "Item" ADD CONSTRAINT "colorItems" FOREIGN KEY ("colorId") REFERENCES "Color" ("id") ON DELETE CASCADE ON UPDATE CASCADE
;






