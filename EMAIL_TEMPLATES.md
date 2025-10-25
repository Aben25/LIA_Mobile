# Email Templates for Love in Action App

## Email Confirmation Template

### Subject: Confirm Your Email - Love in Action

### HTML Template:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Confirm Your Email - Love in Action</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #2c5aa0;
            margin-bottom: 10px;
        }
        .button {
            display: inline-block;
            background-color: #2c5aa0;
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            margin: 20px 0;
            text-align: center;
        }
        .button:hover {
            background-color: #1e3d6f;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #666;
            text-align: center;
        }
        .alternative-link {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            font-size: 14px;
            word-break: break-all;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">Love in Action</div>
            <h1>Welcome to Love in Action!</h1>
        </div>
        
        <p>Hello {{username}},</p>
        
        <p>Thank you for registering with Love in Action. To complete your account setup and start making a difference in children's lives, please confirm your email address.</p>
        
        <div style="text-align: center;">
            <a href="https://thomasasfaw.com/confirm?token={{confirmation_token}}" class="button">
                Confirm Email Address
            </a>
        </div>
        
        <p>If the button above doesn't work, you can also copy and paste this link into your browser:</p>
        
        <div class="alternative-link">
            https://thomasasfaw.com/confirm?token={{confirmation_token}}
        </div>
        
        <p><strong>What happens next?</strong></p>
        <ul>
            <li>Click the confirmation link above</li>
            <li>Your email will be verified</li>
            <li>You'll be taken directly to the Love in Action app</li>
            <li>Start exploring children in need of sponsorship</li>
        </ul>
        
        <p>If you didn't create an account with Love in Action, please ignore this email.</p>
        
        <p>This confirmation link will expire in 24 hours for security reasons.</p>
        
        <div class="footer">
            <p>Love in Action - Making a difference, one child at a time</p>
            <p>If you have any questions, please contact us at support@loveinaction.co</p>
        </div>
    </div>
</body>
</html>
```

### Plain Text Template:
```
Subject: Confirm Your Email - Love in Action

Hello {{username}},

Thank you for registering with Love in Action. To complete your account setup and start making a difference in children's lives, please confirm your email address.

Click this link to confirm your email:
https://thomasasfaw.com/confirm?token={{confirmation_token}}

What happens next?
- Click the confirmation link above
- Your email will be verified
- You'll be taken directly to the Love in Action app
- Start exploring children in need of sponsorship

If you didn't create an account with Love in Action, please ignore this email.

This confirmation link will expire in 24 hours for security reasons.

Love in Action - Making a difference, one child at a time
If you have any questions, please contact us at support@loveinaction.co
```

---

## Password Reset Template

### Subject: Reset Your Password - Love in Action

### HTML Template:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Reset Your Password - Love in Action</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .container {
            background-color: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #2c5aa0;
            margin-bottom: 10px;
        }
        .button {
            display: inline-block;
            background-color: #dc3545;
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            margin: 20px 0;
            text-align: center;
        }
        .button:hover {
            background-color: #c82333;
        }
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            font-size: 12px;
            color: #666;
            text-align: center;
        }
        .alternative-link {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            font-size: 14px;
            word-break: break-all;
        }
        .warning {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            color: #856404;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">Love in Action</div>
            <h1>Password Reset Request</h1>
        </div>
        
        <p>Hello {{username}},</p>
        
        <p>We received a request to reset your password for your Love in Action account. If you made this request, click the button below to reset your password.</p>
        
        <div style="text-align: center;">
            <a href="https://thomasasfaw.com/reset?code={{reset_code}}" class="button">
                Reset My Password
            </a>
        </div>
        
        <p>If the button above doesn't work, you can also copy and paste this link into your browser:</p>
        
        <div class="alternative-link">
            https://thomasasfaw.com/reset?code={{reset_code}}
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
        
        <p>For your security, we recommend choosing a strong password that includes:</p>
        <ul>
            <li>At least 8 characters</li>
            <li>A mix of uppercase and lowercase letters</li>
            <li>Numbers and special characters</li>
        </ul>
        
        <div class="footer">
            <p>Love in Action - Making a difference, one child at a time</p>
            <p>If you have any questions, please contact us at support@loveinaction.co</p>
        </div>
    </div>
</body>
</html>
```

### Plain Text Template:
```
Subject: Reset Your Password - Love in Action

Hello {{username}},

We received a request to reset your password for your Love in Action account. If you made this request, click the link below to reset your password.

Reset your password:
https://thomasasfaw.com/reset?code={{reset_code}}

SECURITY NOTICE: If you didn't request a password reset, please ignore this email. Your password will remain unchanged.

What happens next?
- Click the reset link above
- You'll be taken directly to the Love in Action app
- Enter your new password
- Confirm your new password
- You'll be logged in automatically

This password reset link will expire in 1 hour for security reasons.

For your security, we recommend choosing a strong password that includes:
- At least 8 characters
- A mix of uppercase and lowercase letters
- Numbers and special characters

Love in Action - Making a difference, one child at a time
If you have any questions, please contact us at support@loveinaction.co
```

---

## Template Variables

### Email Confirmation:
- `{{username}}` - User's display name or email
- `{{confirmation_token}}` - The confirmation token from Strapi

### Password Reset:
- `{{username}}` - User's display name or email
- `{{reset_code}}` - The reset code from Strapi

## Implementation Notes

1. **Direct App Links**: Both templates use direct app links (`https://thomasasfaw.com/confirm` and `https://thomasasfaw.com/reset`) instead of HTML redirects
2. **Fallback Support**: The links will work in both the app (via app links) and in browsers (via fallback HTML pages)
3. **Security**: Both templates include security notices and expiration information
4. **User Experience**: Clear instructions on what happens when users click the links
5. **Branding**: Consistent with Love in Action branding and messaging

## Strapi Configuration

In your Strapi admin panel, configure the email templates to use these URLs:

**Email Confirmation URL:**
```
https://thomasasfaw.com/confirm?token={{confirmation_token}}
```

**Password Reset URL:**
```
https://thomasasfaw.com/reset?code={{reset_code}}
```

This ensures that when users click the links in their emails, they'll be taken directly to the app (if installed) or to the fallback web pages.
