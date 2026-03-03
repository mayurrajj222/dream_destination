# Firebase vs Supabase: Security Rules Comparison

## Overview

Both Firebase and Supabase use rules to control data access, but they work differently:

| Feature | Firebase | Supabase |
|---------|----------|----------|
| **Rule System** | Firestore Security Rules | Row Level Security (RLS) Policies |
| **Language** | Custom rules language | PostgreSQL SQL |
| **Location** | Firebase Console | Supabase SQL Editor or UI |
| **Scope** | Collection/Document level | Table/Row level |
| **Testing** | Rules Playground | SQL queries |

## Basic Concepts

### Firebase Security Rules
- Written in a custom rules language
- Applied at collection and document level
- Checked before any read/write operation
- Configured in Firebase Console → Firestore → Rules

### Supabase RLS Policies
- Written in PostgreSQL SQL
- Applied at table and row level
- Checked by PostgreSQL database engine
- Configured in Supabase Dashboard → Authentication → Policies

## Example 1: User-Specific Data Access

### Firebase Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can access their own PSI records
    match /psi_records/{recordId} {
      allow read: if request.auth != null 
                  && request.auth.uid == resource.data.userId;
      
      allow create: if request.auth != null 
                    && request.auth.uid == request.resource.data.userId;
      
      allow update, delete: if request.auth != null 
                            && request.auth.uid == resource.data.userId;
    }
  }
}
```

### Supabase RLS (Equivalent)
```sql
-- Enable RLS on the table
ALTER TABLE psi_records ENABLE ROW LEVEL SECURITY;

-- Policy for reading own records
CREATE POLICY "Users can read own PSI records"
  ON psi_records
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy for creating records
CREATE POLICY "Users can create own PSI records"
  ON psi_records
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy for updating own records
CREATE POLICY "Users can update own PSI records"
  ON psi_records
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy for deleting own records
CREATE POLICY "Users can delete own PSI records"
  ON psi_records
  FOR DELETE
  USING (auth.uid() = user_id);
```

## Example 2: Public Read, Authenticated Write

### Firebase Rules
```javascript
match /trains/{trainId} {
  // Anyone can read trains
  allow read: if true;
  
  // Only authenticated users can write
  allow write: if request.auth != null;
}
```

### Supabase RLS (Equivalent)
```sql
-- Enable RLS
ALTER TABLE trains ENABLE ROW LEVEL SECURITY;

-- Anyone can read (even unauthenticated)
CREATE POLICY "Anyone can read trains"
  ON trains
  FOR SELECT
  USING (true);

-- Only authenticated users can insert
CREATE POLICY "Authenticated users can create trains"
  ON trains
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Only authenticated users can update
CREATE POLICY "Authenticated users can update trains"
  ON trains
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Only authenticated users can delete
CREATE POLICY "Authenticated users can delete trains"
  ON trains
  FOR DELETE
  TO authenticated
  USING (true);
```

## Example 3: Admin-Only Access

### Firebase Rules
```javascript
match /admin_data/{docId} {
  allow read, write: if request.auth != null 
                     && request.auth.token.admin == true;
}
```

### Supabase RLS (Equivalent)
```sql
-- First, add admin flag to user metadata
-- Then create policy

ALTER TABLE admin_data ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admins can access"
  ON admin_data
  FOR ALL
  USING (
    auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE raw_user_meta_data->>'role' = 'admin'
    )
  );
```

## Example 4: Conditional Field Access

### Firebase Rules
```javascript
match /employees/{empId} {
  // Users can read their own employee record
  allow read: if request.auth.uid == resource.data.userId;
  
  // Users can only update certain fields
  allow update: if request.auth.uid == resource.data.userId
                && !request.resource.data.diff(resource.data)
                   .affectedKeys().hasAny(['salary', 'role']);
}
```

### Supabase RLS (Equivalent)
```sql
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Read own record
CREATE POLICY "Users can read own employee record"
  ON employees
  FOR SELECT
  USING (auth.uid() = user_id);

-- Update own record (field-level control requires triggers)
CREATE POLICY "Users can update own employee record"
  ON employees
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- For field-level restrictions, use a trigger:
CREATE OR REPLACE FUNCTION check_employee_update()
RETURNS TRIGGER AS $$
BEGIN
  -- Prevent updating salary and role
  IF OLD.salary IS DISTINCT FROM NEW.salary 
     OR OLD.role IS DISTINCT FROM NEW.role THEN
    RAISE EXCEPTION 'Cannot update salary or role';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER employee_update_check
  BEFORE UPDATE ON employees
  FOR EACH ROW
  EXECUTE FUNCTION check_employee_update();
```

## Key Differences

### 1. Syntax
- **Firebase:** Custom rules language (JavaScript-like)
- **Supabase:** Standard PostgreSQL SQL

### 2. Granularity
- **Firebase:** Collection and document level
- **Supabase:** Table and row level (can use triggers for field-level)

### 3. Testing
- **Firebase:** Built-in Rules Playground
- **Supabase:** Test with SQL queries or API calls

### 4. Performance
- **Firebase:** Rules evaluated on every request
- **Supabase:** Policies compiled into SQL queries (generally faster)

### 5. Complexity
- **Firebase:** Simpler for basic rules, complex for advanced logic
- **Supabase:** More powerful with SQL, steeper learning curve

## Common Patterns

### Pattern 1: User Owns Resource

**Firebase:**
```javascript
allow read, write: if request.auth.uid == resource.data.userId;
```

**Supabase:**
```sql
USING (auth.uid() = user_id)
```

### Pattern 2: Authenticated Users Only

**Firebase:**
```javascript
allow read, write: if request.auth != null;
```

**Supabase:**
```sql
TO authenticated
USING (true)
```

### Pattern 3: Public Read, Private Write

**Firebase:**
```javascript
allow read: if true;
allow write: if request.auth != null;
```

**Supabase:**
```sql
-- Read policy
FOR SELECT USING (true)

-- Write policy
FOR INSERT TO authenticated WITH CHECK (true)
```

## Migration Tips

When migrating from Firebase to Supabase:

1. **Identify your Firebase rules** - Document what each rule does
2. **Map to RLS policies** - Convert each rule to equivalent SQL
3. **Test thoroughly** - Verify policies work as expected
4. **Use helper functions** - Create SQL functions for complex logic
5. **Monitor logs** - Check Supabase logs for policy violations

## Quick Reference

### Firebase Functions → Supabase Equivalents

| Firebase | Supabase |
|----------|----------|
| `request.auth.uid` | `auth.uid()` |
| `request.auth.token.email` | `auth.email()` |
| `resource.data.field` | `field` (column name) |
| `request.resource.data.field` | `field` (in WITH CHECK) |
| `request.auth != null` | `TO authenticated` |
| `get(/path/to/doc)` | SQL JOIN or subquery |

## Your Current Setup

For your PSI records, you need this RLS policy:

```sql
-- Enable RLS
ALTER TABLE psi_records ENABLE ROW LEVEL SECURITY;

-- Users can only access their own records
CREATE POLICY "user_isolation_policy"
  ON psi_records
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

This is equivalent to your Firebase rule:
```javascript
allow read, write: if request.auth.uid == resource.data.userId;
```

## Next Steps

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Run the RLS setup SQL from `SUPABASE_RLS_SETUP.md`
4. Test by signing up and creating a PSI record
5. Verify you can only see your own data

The security model is similar to Firebase, just expressed in SQL instead of rules language!
