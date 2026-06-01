-- RBAC: profiles UPDATE policies (staff same-school, own profile)
BEGIN;
\ir _helpers.sql

SELECT plan(4);

SELECT tests.clear_auth();

SELECT has_extension('pgtap', 'pgTAP extension is available');

-- Fixture: two schools, staff + parent in school A, parent in school B
SELECT tests.create_school('School A') AS school_a \gset
SELECT tests.create_school('School B') AS school_b \gset

SELECT tests.create_user('school_staff', :'school_a'::uuid, 'staff-a@test.local', 'Staff A') AS staff_a \gset
SELECT tests.create_user('parent',       :'school_a'::uuid, 'parent-a@test.local', 'Parent A') AS parent_a \gset
SELECT tests.create_user('parent',       :'school_b'::uuid, 'parent-b@test.local', 'Parent B') AS parent_b \gset

-- Staff can UPDATE same-school parent profile
SELECT tests.authenticate_as(:'staff_a'::uuid);
UPDATE profiles SET phone = '+966500000001' WHERE id = :'parent_a'::uuid;
SELECT ok(
  (SELECT phone FROM profiles WHERE id = :'parent_a'::uuid) = '+966500000001',
  'staff can update same-school parent profile'
);

-- Parent cannot update another parent in same school
SELECT tests.authenticate_as(:'parent_a'::uuid);
UPDATE profiles SET phone = '+966500000002' WHERE id = :'parent_b'::uuid;
SELECT ok(
  (SELECT phone FROM profiles WHERE id = :'parent_b'::uuid) IS DISTINCT FROM '+966500000002',
  'parent cannot update another user profile'
);

-- Staff cannot update cross-school profile
SELECT tests.authenticate_as(:'staff_a'::uuid);
UPDATE profiles SET phone = '+966500000003' WHERE id = :'parent_b'::uuid;
SELECT ok(
  (SELECT phone FROM profiles WHERE id = :'parent_b'::uuid) IS DISTINCT FROM '+966500000003',
  'staff cannot update cross-school profile'
);

-- User can update own profile
SELECT tests.authenticate_as(:'parent_a'::uuid);
UPDATE profiles SET phone = '+966500000099' WHERE id = :'parent_a'::uuid;
SELECT ok(
  (SELECT phone FROM profiles WHERE id = :'parent_a'::uuid) = '+966500000099',
  'user can update own profile'
);

SELECT * FROM finish();
ROLLBACK;
