INSERT INTO "Organization" ("id", "displayName") VALUES
    (1, '{"tr": "Alpha Corp."}'),
    (2, '{"tr": "Beta Corp."}'),
    (3, '{"tr": "Gamma Corp."}'),
    (4, '{"tr": "Zeta Corp."}');

ALTER SEQUENCE "BusinessUnit_id_seq" RESTART WITH 1;

INSERT INTO "BusinessUnit" ("id", "organizationId", "parentId", "displayName") VALUES
    (101, 1, 1, '{"tr": "A Marketing"}'),
    (111, 1, 101, '{"tr": "A Tele Marketing"}'),
    (112, 1, 101, '{"tr": "A Direct Marketing"}'),
    (121, 1, 111, '{"tr": "A Tele Phone Marketing"}'),
    (122, 1, 111, '{"tr": "A Tele Visual Marketing"}'),
    (102, 1, 101, '{"tr": "A Project"}'),
    (150, 1, 1, '{"tr": "A Special Dep"}'),
    (201, 2, 2, '{"tr": "B Marketing"}'),
    (211, 2, 201, '{"tr": "B Tele Marketing"}'),
    (212, 2, 201, '{"tr": "B Direct Marketing"}'),
    (221, 2, 211, '{"tr": "B Tele Phone Marketing"}'),
    (222, 2, 211, '{"tr": "B Tele Visual Marketing"}'),
    (202, 2, 201, '{"tr": "B Project"}');

INSERT INTO "AppUser" ("id", "organizationId", "businessUnitId", "name", "surname", "email", "password") VALUES
    (1, 1, 1, 'Oz', '-', 'oz@x.com', '1'),
    (2, 1, 101, 'Tim', '-', 'tim@x.com', '1'),
    (3, 1, 111, 'Mary', '-', 'mary@x.com', '1'),
    (4, 1, 112, 'Susan', '-', 'susan@x.com', '1'),
    (5, 1, 112, 'Sam', '-', 'sam@x.com', '1'),
    (6, 1, 121, 'Hans', '-', 'hans@x.com', '1'),
    (7, 1, 122, 'Liam', '-', 'liam@x.com', '1'),
    (8, 1, 102, 'Furlong', '-', 'furlong@x.com', '1'),
    (9, 1, 150, 'Alfred', '-', 'alfred@x.com', '1'),
    (21, 2, 2, 'John', '-', 'john@x.com', '1');

INSERT INTO "SecurityRole" ("id", "organizationId", "displayName") VALUES
    (1, 1, '{"tr": "CEO"}'),
    (2, 1, '{"tr": "Marketing Director"}'),
    (3, 1, '{"tr": "Marketing Manager"}'),
    (4, 1, '{"tr": "Marketing Expert"}'),
    (5, 1, '{"tr": "Project Director"}'),
    (6, 1, '{"tr": "Project Manager"}');

INSERT INTO "EntityGroup" ("id", "name", "displayName") VALUES (1, 'General', '{ "tr": "General" }');

INSERT INTO "Entity" ("id", "entityGroupId", "organizationId", "name") VALUES
    (1, 1, NULL, 'Account'),
    (2, 1, NULL, 'Person'),
    (3, 1, NULL, 'Project'),
    (101, 1, 1, 'Table of Alpha');

INSERT INTO "Field" ("id", "entityId", "organizationId", "name", "isSecure") VALUES
    (11, 1, NULL, 'account name', FALSE),
    (12, 1, NULL, 'status', FALSE),
    (13, 1, NULL, 'dept', TRUE),
    (21, 2, NULL, 'name', FALSE),
    (22, 2, NULL, 'surname', FALSE),
    (23, 2, NULL, 'semi public field', FALSE),
    (24, 2, NULL, 'semi private field', TRUE),
    (31, 3, NULL, 'manager', FALSE),
    (32, 3, NULL, 'total', TRUE),
    (1011, 101, NULL, 'public field', FALSE),
    (1012, 101, NULL, 'not so public field', FALSE),
    (1013, 101, NULL, 'semi secure field', TRUE),
    (1014, 101, NULL, 'secure field', TRUE);

INSERT INTO "FieldCustomization" ("fieldId", "organizationId", "isSecure") VALUES
    (23, 1, TRUE),
    (24, 1, FALSE),
    (1012, 1, TRUE),
    (1013, 1, FALSE);






