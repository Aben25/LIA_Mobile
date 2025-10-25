# Strapi Email Template Troubleshooting

## Issue: EJS Template Not Processing

The email template is still showing literal `<%= CODE %>` instead of the actual reset code. This means Strapi is not processing the EJS template correctly.

## Possible Causes & Solutions

### 1. **Template Engine Configuration Issue**

**Check if EJS is enabled in Strapi:**

1. Go to your Strapi project folder
2. Check `package.json` for EJS dependency:
```json
{
  "dependencies": {
    "ejs": "^3.1.9"
  }
}
```

3. If EJS is missing, install it:
```bash
npm install ejs
```

4. Restart Strapi server

### 2. **Template Syntax Issue**

**Try different EJS syntax variations:**

**Option A: Standard EJS**
```html
https://thomasasfaw.com/reset?code=<%= CODE %>
```

**Option B: With spaces (sometimes needed)**
```html
https://thomasasfaw.com/reset?code=<%= CODE %>
```

**Option C: Alternative syntax**
```html
https://thomasasfaw.com/reset?code=<%=CODE%>
```

### 3. **Strapi Version Compatibility**

**Check your Strapi version:**
```bash
npm list @strapi/strapi
```

**For Strapi v4+, try this syntax:**
```html
https://thomasasfaw.com/reset?code={{CODE}}
```

**For Strapi v3, use EJS:**
```html
https://thomasasfaw.com/reset?code=<%= CODE %>
```

### 4. **Template Location Issue**

**Make sure you're editing the correct template:**

1. Go to **Settings** → **Users & Permissions Plugin** → **Email Templates**
2. Look for **"Reset password"** template (not "Password reset")
3. Make sure you're editing the HTML version, not just the text version

### 5. **Cache Issue**

**Clear Strapi cache:**

1. Stop Strapi server
2. Delete `.cache` folder in your Strapi project
3. Restart Strapi server
4. Try sending another password reset email

### 6. **Alternative: Use Strapi's Built-in Variables**

**Try using Strapi's default variables:**

```html
https://thomasasfaw.com/reset?code=<%= token %>
```

or

```html
https://thomasasfaw.com/reset?code=<%= resetToken %>
```

### 7. **Check Strapi Logs**

**Look at Strapi server logs for errors:**

1. Check your Strapi console output
2. Look for any template processing errors
3. Check for EJS-related error messages

## Step-by-Step Debugging

### Step 1: Verify Template Engine
```bash
# In your Strapi project directory
npm list ejs
```

### Step 2: Check Strapi Version
```bash
npm list @strapi/strapi
```

### Step 3: Test Different Syntax
Try these variations in your template:

**Version 1:**
```html
https://thomasasfaw.com/reset?code=<%= CODE %>
```

**Version 2:**
```html
https://thomasasfaw.com/reset?code=<%=token%>
```

**Version 3:**
```html
https://thomasasfaw.com/reset?code={{CODE}}
```

### Step 4: Check URL Template Setting
In Strapi admin:
1. Go to **Settings** → **Users & Permissions Plugin** → **Advanced Settings**
2. Make sure **"Password reset URL template"** is set to:
```
https://thomasasfaw.com/reset?code=<%= CODE %>
```

### Step 5: Test with Simple Template
Try a minimal template first:

**HTML:**
```html
<p>Reset your password: <a href="https://thomasasfaw.com/reset?code=<%= CODE %>">Click here</a></p>
```

**Text:**
```
Reset your password: https://thomasasfaw.com/reset?code=<%= CODE %>
```

## Quick Fix Attempts

### Attempt 1: Reinstall EJS
```bash
cd your-strapi-project
npm uninstall ejs
npm install ejs@latest
npm run develop
```

### Attempt 2: Use Different Variable Name
```html
https://thomasasfaw.com/reset?code=<%= resetToken %>
```

### Attempt 3: Check Strapi Documentation
Look at your Strapi version's documentation for the correct template syntax.

## What to Check Next

1. **What version of Strapi are you using?**
2. **Is EJS installed in your Strapi project?**
3. **Are you editing the correct template in the admin panel?**
4. **Have you restarted Strapi after making changes?**
5. **Are there any errors in the Strapi server logs?**

## Expected Result

After fixing, the email should show:
```
https://thomasasfaw.com/reset?code=abc123def456ghi789
```

Instead of:
```
https://thomasasfaw.com/reset?code=<%= CODE %>
```

Let me know what you find when you check these items, and I can help you with the specific solution for your Strapi setup!
