# Correct Password Reset Template for Your Case

## Current Working Template Structure

Your current template is working correctly with these variables:
- `<%= URL %>` - The base URL
- `<%= TOKEN %>` - The reset token

## The Issue

The template is generating:
```
https://loveinaction.co/auth/reset-password?code=...
```

But we need:
```
https://thomasasfaw.com/reset?code=...
```

## Solution: Update the Template

### Option 1: Simple Template (Recommended)

**HTML Template:**
```html
<p>We heard that you lost your password. Sorry about that!</p>

<p>But don't worry! You can use the following link to reset your password:</p>
<p><a href="https://thomasasfaw.com/reset?code=<%= TOKEN %>">Reset My Password</a></p>

<p>Or copy and paste this link into your browser:</p>
<p>https://thomasasfaw.com/reset?code=<%= TOKEN %></p>

<p>This link will expire in 1 hour for security reasons.</p>

<p>If you didn't request a password reset, please ignore this email.</p>

<p>Thanks.</p>
```

**Plain Text Template:**
```
We heard that you lost your password. Sorry about that!

But don't worry! You can use the following link to reset your password:

https://thomasasfaw.com/reset?code=<%= TOKEN %>

This link will expire in 1 hour for security reasons.

If you didn't request a password reset, please ignore this email.

Thanks.
```

### Option 2: Enhanced Template with Styling

**HTML Template:**
```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
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
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin: 10px 0;
            word-break: break-all;
        }
        .warning {
            background-color: #fff3cd;
            border-left: 5px solid #ffc107;
            padding: 10px;
            margin: 20px 0;
            color: #856404;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Password Reset Request</h1>
        
        <p>We heard that you lost your password. Sorry about that!</p>
        
        <p>But don't worry! You can use the following link to reset your password:</p>
        
        <div style="text-align: center;">
            <a href="https://thomasasfaw.com/reset?code=<%= TOKEN %>" class="button">
                Reset My Password
            </a>
        </div>
        
        <p>Or copy and paste this link into your browser:</p>
        
        <div class="alternative-link">
            https://thomasasfaw.com/reset?code=<%= TOKEN %>
        </div>
        
        <div class="warning">
            <strong>Security Notice:</strong> If you didn't request a password reset, please ignore this email. Your password will remain unchanged.
        </div>
        
        <p>This link will expire in 1 hour for security reasons.</p>
        
        <p>Thanks.</p>
    </div>
</body>
</html>
```

## How to Update in Strapi

### Step 1: Update Email Template
1. Go to **Settings** → **Users & Permissions Plugin** → **Email Templates**
2. Find the **"Reset password"** template
3. Replace the current template with one of the options above
4. Save the template

### Step 2: Update URL Template (if needed)
1. Go to **Settings** → **Users & Permissions Plugin** → **Advanced Settings**
2. Look for **"Password reset URL template"**
3. Set it to: `https://thomasasfaw.com/reset?code=<%= TOKEN %>`

## Key Changes Made

1. **Changed URL structure**: From `https://loveinaction.co/auth/reset-password?code=` to `https://thomasasfaw.com/reset?code=`
2. **Used correct variable**: `<%= TOKEN %>` instead of `<%= CODE %>`
3. **Added security notice**: Warning about ignoring if not requested
4. **Added expiration notice**: 1 hour expiration
5. **Added alternative link**: Copy-paste option for users

## Expected Result

After updating, the email should generate:
```
https://thomasasfaw.com/reset?code=c0275201cf9ff930ff1661dbcde8fa6ea0c7aea87a4c62f5e268bf43f1c38da8d41657f1b68ad738f964ba01c12460a45b2fcf9aca88e8a91638751c916ef55f
```

## Testing

1. **Update the template** in Strapi
2. **Request a new password reset** from your app
3. **Check the email** - should now have the correct URL structure
4. **Click the link** - should open your app and work properly

The password reset should now work perfectly with the correct URL structure! 🎉
