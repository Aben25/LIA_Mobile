# Password Reset Template Specific Debug

## Key Insight: Email Confirmation Works, Password Reset Doesn't

Since the email confirmation template is working correctly with `<%= CODE %>` syntax, but the password reset template is not, this indicates:

1. ✅ **EJS is properly installed and configured**
2. ✅ **Strapi version supports EJS syntax**
3. ❌ **Password reset template has a specific configuration issue**

## Possible Causes

### 1. **Different Template Locations**
Email confirmation and password reset might be configured in different places in Strapi.

**Check both locations:**
- **Settings** → **Users & Permissions Plugin** → **Email Templates**
- **Settings** → **Users & Permissions Plugin** → **Advanced Settings**

### 2. **URL Template vs Email Template Mismatch**
The password reset might be using a different URL template setting.

**Check Advanced Settings:**
1. Go to **Settings** → **Users & Permissions Plugin** → **Advanced Settings**
2. Look for **"Password reset URL template"**
3. Make sure it's set to: `https://thomasasfaw.com/reset?code=<%= CODE %>`

### 3. **Template Name Mismatch**
Strapi might be looking for a different template name.

**Check template names:**
- Email confirmation: "Email confirmation" or "Confirmation"
- Password reset: "Reset password" or "Password reset"

### 4. **Template Override Issue**
The password reset template might be overridden by a custom template.

## Step-by-Step Debugging

### Step 1: Compare Working vs Non-Working Templates

**Check the email confirmation template that's working:**
1. Go to **Settings** → **Users & Permissions Plugin** → **Email Templates**
2. Find the **"Email confirmation"** template
3. Note the exact syntax used: `<%= CODE %>`
4. Copy this exact syntax

**Check the password reset template:**
1. Find the **"Reset password"** template
2. Compare the syntax with the working template
3. Make sure they match exactly

### Step 2: Check Advanced Settings

**Verify URL template settings:**
1. Go to **Settings** → **Users & Permissions Plugin** → **Advanced Settings**
2. Check **"Email confirmation URL template"** (this should be working)
3. Check **"Password reset URL template"** (this might be the issue)

**Expected settings:**
```
Email confirmation URL template: https://thomasasfaw.com/confirm?token=<%= CODE %>
Password reset URL template: https://thomasasfaw.com/reset?code=<%= CODE %>
```

### Step 3: Test Template Syntax

**Try copying the exact working syntax:**
1. Copy the exact `<%= CODE %>` syntax from the working email confirmation template
2. Paste it into the password reset template
3. Make sure there are no extra spaces or characters

### Step 4: Check Template Variables

**Verify available variables:**
Some Strapi versions use different variable names:
- `<%= CODE %>` (most common)
- `<%= token %>`
- `<%= resetToken %>`
- `<%= code %>` (lowercase)

### Step 5: Template Cache Issue

**Clear template cache:**
1. Stop Strapi server
2. Delete `.cache` folder
3. Restart Strapi
4. Test password reset again

## Quick Fix Attempts

### Attempt 1: Copy Working Template Syntax
1. Go to the working email confirmation template
2. Copy the exact `<%= CODE %>` syntax
3. Paste it into the password reset template
4. Save and test

### Attempt 2: Check URL Template Setting
1. Go to **Advanced Settings**
2. Make sure **"Password reset URL template"** is set correctly
3. Use the exact same syntax as the working email confirmation URL template

### Attempt 3: Use Different Variable Name
Try these variations in the password reset template:
```html
https://thomasasfaw.com/reset?code=<%= token %>
```
```html
https://thomasasfaw.com/reset?code=<%= resetToken %>
```
```html
https://thomasasfaw.com/reset?code=<%= code %>
```

## What to Check Right Now

1. **Compare the working email confirmation template with the password reset template**
2. **Check if the URL template setting in Advanced Settings is correct**
3. **Make sure you're editing the right template (there might be multiple password reset templates)**

## Expected Result

After fixing, the password reset email should show:
```
https://thomasasfaw.com/reset?code=abc123def456ghi789
```

Just like the working email confirmation shows:
```
https://thomasasfaw.com/confirm?token=abc123def456ghi789
```

## Most Likely Solution

Since email confirmation works, the issue is probably:
1. **Wrong URL template setting** in Advanced Settings
2. **Different template name** or location
3. **Template cache issue** requiring a restart

Try checking the Advanced Settings first - that's the most likely culprit!
