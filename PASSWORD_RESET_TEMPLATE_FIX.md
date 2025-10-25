# Password Reset Template Fix

## Issue Identified

The password reset email template in your Strapi backend is still using the literal text `<%= CODE %>` instead of the actual reset code. This is the same issue we had with the email confirmation template.

## Evidence from Terminal

```
D/com.llfbandit.app_links(18905): Handled intent: action: android.intent.action.VIEW / data: https://thomasasfaw.com/reset?code=%3C%= CODE %>
```

The URL contains `%3C%= CODE %>` which is the URL-encoded version of `<%= CODE %>` - this means the template is not being processed correctly.

## Root Cause

Your Strapi email templates are still using the old incorrect syntax. You need to update them with the correct EJS template syntax.

## The Fix

### 1. Update Your Strapi Password Reset Template

In your Strapi admin panel:
1. Go to **Settings** → **Users & Permissions Plugin** → **Email Templates**
2. Find the **Password Reset** template
3. Replace the current template with the correct one from `CORRECT_EMAIL_TEMPLATES.md`

### 2. Correct Password Reset Template

**Subject:** `Reset Your Password - Love in Action`

**HTML Template:**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 8px; }
        .header { text-align: center; margin-bottom: 20px; }
        .logo { font-size: 24px; font-weight: bold; color: #E53935; }
        .button {
            display: inline-block;
            background-color: #E53935;
            color: #ffffff;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .alternative-link {
            word-break: break-all;
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
        }
        .warning {
            background-color: #fff3cd;
            border-left: 5px solid #ffc107;
            padding: 10px;
            margin-top: 20px;
            color: #856404;
        }
        .footer { text-align: center; margin-top: 30px; font-size: 0.9em; color: #777; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">Love in Action</div>
            <h1>Password Reset Request</h1>
        </div>

        <p>Hello <strong><%= user.username %></strong>,</p>

        <p>We received a request to reset your password for your Love in Action account. If you made this request, click the button below to reset your password.</p>

        <div style="text-align: center;">
            <a href="https://thomasasfaw.com/reset?code=<%= CODE %>" class="button">
                Reset My Password
            </a>
        </div>

        <p>If the button above doesn't work, you can also copy and paste this link into your browser:</p>

        <div class="alternative-link">
            https://thomasasfaw.com/reset?code=<%= CODE %>
        </div>

        <div class="warning">
            <strong>Security Notice:</strong> If you didn't request a password reset, please ignore this email. Your password will remain unchanged.
        </div>

        <p><strong>What happens next?</strong></p>
        <ul>
            <li>Click the reset link above</li>
            <li>You'll be taken directly to the Love in Action app</li>
            <li>Enter your new password</li>
            <li>Confirm your new password</li>
            <li>You'll be logged in automatically</li>
        </ul>

        <p>This password reset link will expire in 1 hour for security reasons.</p>

        <div class="footer">
            Love in Action - Making a difference, one child at a time<br>
            If you have any questions, please contact us at info@loveinaction.co
        </div>
    </div>
</body>
</html>
```

**Plain Text Template:**
```
Subject: Reset Your Password - Love in Action

Hello <%= user.username %>,

We received a request to reset your password for your Love in Action account. If you made this request, click the link below to reset your password.

Reset your password:
https://thomasasfaw.com/reset?code=<%= CODE %>

SECURITY NOTICE: If you didn't request a password reset, please ignore this email. Your password will remain unchanged.

What happens next?
- Click the reset link above
- You'll be taken directly to the Love in Action app
- Enter your new password
- Confirm your new password
- You'll be logged in automatically

This password reset link will expire in 1 hour for security reasons.

Love in Action - Making a difference, one child at a time
If you have any questions, please contact us at info@loveinaction.co
```

### 3. Set the Password Reset URL Template

In your Strapi admin panel:
1. Go to **Settings** → **Users & Permissions Plugin** → **Advanced Settings**
2. Set **Password reset URL template** to:
```
https://thomasasfaw.com/reset?code=<%= CODE %>
```

## Key Points

### ✅ **Correct EJS Syntax:**
- `<%= CODE %>` - This is the correct EJS syntax for the reset code
- `<%= user.username %>` - This is the correct EJS syntax for the username

### ❌ **What You Currently Have:**
- Literal text `<%= CODE %>` instead of the actual code
- This means the template is not being processed by Strapi

### 🔧 **What You Need to Do:**
1. **Copy the correct template** from above
2. **Paste it into your Strapi email template settings**
3. **Set the URL template** to use `<%= CODE %>`
4. **Test with a new password reset request**

## Expected Result After Fix

### ✅ **Correct URL:**
```
https://thomasasfaw.com/reset?code=abc123def456ghi789
```

### ❌ **Current Broken URL:**
```
https://thomasasfaw.com/reset?code=%3C%= CODE %>
```

## Testing Steps

1. **Update the Strapi template** with the correct version above
2. **Set the URL template** in Strapi advanced settings
3. **Request a new password reset** from your app
4. **Check the email** - the link should contain the actual reset code
5. **Click the link** - should open the app and work properly

## Why This Happens

Strapi uses EJS (Embedded JavaScript) templating, not Handlebars. The correct syntax is:
- `<%= variable %>` for outputting variables
- `<%= user.username %>` for user data
- `<%= CODE %>` for the reset/confirmation code

The literal text `<%= CODE %>` means the template engine isn't processing the template correctly, which usually happens when:
1. The template syntax is wrong
2. The template isn't saved properly
3. The URL template isn't set correctly

Once you update the Strapi templates with the correct EJS syntax, the password reset should work perfectly! 🎉
