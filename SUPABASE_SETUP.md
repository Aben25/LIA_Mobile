# Supabase Setup Guide for Love in Action Flutter App

## Prerequisites
- Supabase account and project
- Flutter development environment

## Step 1: Get Your Supabase Credentials

1. Go to [supabase.com](https://supabase.com) and sign in
2. Select your project (or create a new one)
3. Go to **Settings** → **API**
4. Copy your **Project URL** and **anon public** key

## Step 2: Supabase Credentials Already Configured! ✅

Great news! Your Flutter app is already configured with the **exact same Supabase credentials** as your Expo project:

- **Project URL**: `https://ntckmekstkqxqgigqzgn.supabase.co`
- **API Key**: Already configured in `lib/config/env.dart`
- **Project ID**: `b0196b01-e63b-4bf8-a0b4-3edacc926fc7`

No additional configuration needed! 🎉

## Step 3: Ready to Test! 🚀

Your Flutter app is now configured with the **exact same Supabase project** as your Expo app. You can test the authentication immediately!

## Step 4: Configure Supabase Authentication

1. In your Supabase dashboard, go to **Authentication** → **Settings**
2. Configure your authentication settings:
   - **Enable email confirmations** (recommended for production)
   - **Enable email change confirmations**
   - **Enable password reset**

## Step 5: Set Up Database Tables (Optional)

If you want to store additional user data, create tables in Supabase:

```sql
-- Example: Create a profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);
```

## Step 6: Run the App

```bash
# Run the app normally (credentials are already configured)
flutter run
```

## Step 7: Test the Integration

1. Run the app using one of the methods above
2. Try to register a new account
3. Check your email for confirmation
4. Try to sign in

## Troubleshooting

### Common Issues:

1. **"Invalid API key" error**
   - Double-check your anon key in `env.dart`
   - Ensure the key is from the correct project

2. **"URL not found" error**
   - Verify your Supabase URL in `env.dart`
   - Check if your project is active

3. **Email confirmation not working**
   - Check Supabase Authentication settings
   - Verify email templates in Supabase dashboard

4. **Build errors**
   - Run `flutter clean` and `flutter pub get`
   - Ensure all dependencies are properly installed

## Security Notes

- Never commit your actual Supabase credentials to version control
- Use environment variables or secure configuration management in production
- The anon key is safe to use in client apps (it has limited permissions)
- Consider implementing additional security measures like rate limiting

## Next Steps

After successful authentication setup:
1. Implement user profile management
2. Add data fetching from Supabase tables
3. Implement real-time subscriptions
4. Add file upload functionality
5. Set up proper error handling and loading states
