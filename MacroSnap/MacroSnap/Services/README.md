# Authentication Setup Guide

This guide walks you through setting up authentication for MacroSnap, including Sign in with Apple and email/password authentication with Supabase.

## Prerequisites

1. A Supabase project (create one at https://app.supabase.com)
2. Xcode 15.0 or later
3. An Apple Developer account (for Sign in with Apple)

---

## Step 1: Add Supabase Swift Package

### 1.1 Add Package Dependency

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the Supabase Swift repository URL: `https://github.com/supabase/supabase-swift`
3. Select "Up to Next Major Version" with version `2.0.0`
4. Click **Add Package**
5. Select the following products:
   - `Supabase`
   - `Auth` (included in Supabase)
   - `PostgREST` (included in Supabase)
   - `Realtime` (optional, for real-time features)
   - `Storage` (optional, for file uploads)
6. Click **Add Package**

---

## Step 2: Configure Supabase

### 2.1 Get Your Supabase Credentials

1. Go to your Supabase project dashboard at https://app.supabase.com
2. Navigate to **Settings** → **API**
3. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **Anon/Public Key** (starts with `eyJhbGc...`)

### 2.2 Update SupabaseConfig.swift

Open `Services/SupabaseConfig.swift` and replace the placeholder values:

```swift
static let url = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
static let anonKey = "YOUR_ANON_KEY_HERE"
```

**Important**: Never commit these credentials to a public repository. Consider using environment variables or a `.xcconfig` file for production apps.

---

## Step 3: Apply Database Migration

The authentication system requires the database schema created in Task 1.

### 3.1 Run the Migration

1. Navigate to your Supabase project dashboard
2. Go to **SQL Editor**
3. Open `/supabase/migrations/20250124000001_initial_schema.sql`
4. Copy the entire SQL file
5. Paste it into the Supabase SQL Editor
6. Click **Run**

This creates the following tables:
- `profiles` - User profiles (extends auth.users)
- `goals` - Daily macro goals
- `macro_entries` - Individual macro logs
- `macro_presets` - Saved meal presets (Pro feature)
- `daily_macro_totals` - Materialized view for quick lookups

---

## Step 4: Configure Sign in with Apple

### 4.1 Enable Sign in with Apple in Xcode

1. Open your project in Xcode
2. Select your app target (MacroSnap)
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **Sign in with Apple**
6. Make sure your team is selected and provisioning profile is valid

### 4.2 Enable Sign in with Apple in Supabase

1. Go to your Supabase dashboard
2. Navigate to **Authentication** → **Providers**
3. Find **Apple** in the list
4. Toggle **Enable Sign in with Apple**

#### 4.2.1 Get Your Apple Service ID

1. Go to https://developer.apple.com/account/resources/identifiers/list
2. Click the **+** button to create a new identifier
3. Select **Services IDs** and click **Continue**
4. Fill in:
   - **Description**: MacroSnap Auth
   - **Identifier**: `com.yourcompany.macrosnap.auth` (must be unique)
5. Click **Continue** and **Register**

#### 4.2.2 Configure Your Service ID

1. Select your newly created Service ID
2. Enable **Sign in with Apple**
3. Click **Configure**
4. Add your domain and return URLs:
   - **Domains**: `YOUR_PROJECT_ID.supabase.co`
   - **Return URLs**: `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback`
5. Click **Save** and **Continue**

#### 4.2.3 Create a Private Key

1. Go to https://developer.apple.com/account/resources/authkeys/list
2. Click the **+** button to create a new key
3. Name it "MacroSnap Auth Key"
4. Enable **Sign in with Apple**
5. Click **Configure** and select your Primary App ID
6. Click **Continue** and **Register**
7. **Download the key** (you can only do this once!)
8. Note the **Key ID** (e.g., ABC123DEFG)

#### 4.2.4 Complete Supabase Configuration

Back in Supabase:

1. Upload your downloaded `.p8` key file
2. Enter your **Team ID** (found at https://developer.apple.com/account)
3. Enter your **Key ID**
4. Enter your **Bundle ID** (e.g., `com.yourcompany.macrosnap`)
5. Enter your **Service ID** (created in step 4.2.1)
6. Click **Save**

---

## Step 5: Configure Email/Password Authentication

Email/password authentication is enabled by default in Supabase, but you may want to customize the settings.

### 5.1 Email Templates (Optional)

1. Go to **Authentication** → **Email Templates** in Supabase
2. Customize the templates for:
   - Confirmation email
   - Password reset
   - Magic link

### 5.2 Email Provider (Optional)

By default, Supabase uses a built-in email service (limited to 3 emails/hour during development).

For production, configure a custom SMTP provider:

1. Go to **Authentication** → **Settings**
2. Scroll to **SMTP Settings**
3. Configure your SMTP provider (SendGrid, AWS SES, etc.)

---

## Step 6: Test Authentication

### 6.1 Run the App

1. Build and run the app in Xcode (**Cmd+R**)
2. You should see the Welcome screen

### 6.2 Test Sign in with Apple

1. Tap "Continue with Apple"
2. Authenticate with Face ID/Touch ID
3. You should be signed in and see the main app screen

### 6.3 Test Email/Password Sign Up

1. Enter an email and password (min 6 characters)
2. Tap "Sign Up"
3. Check your email for a confirmation link (if email confirmation is enabled)
4. You should be signed in after confirmation

### 6.4 Verify in Supabase

1. Go to **Authentication** → **Users** in Supabase
2. You should see your newly created user(s)
3. Check the **Table Editor** → **profiles** to see the created profile

---

## Step 7: Session Persistence

Session persistence is handled automatically by Supabase Auth. The session is stored securely in the keychain and restored on app launch.

### How It Works

1. User signs in → Session created and stored
2. App closes → Session persists in keychain
3. App reopens → `AuthenticationService.checkAuthenticationState()` restores session
4. User is automatically signed in

### Sign Out

To sign out:

```swift
try await authService.signOut()
```

This clears the session from the keychain and Supabase.

---

## Troubleshooting

### "Invalid credentials" error

- Check that your Supabase URL and anon key are correct in `SupabaseConfig.swift`
- Verify the database migration was applied successfully

### Sign in with Apple not working

- Ensure "Sign in with Apple" capability is added in Xcode
- Verify your Service ID and Return URLs are correct in Apple Developer Portal
- Check that your `.p8` key and IDs are correct in Supabase

### Email confirmation not received

- Check your spam folder
- Verify SMTP settings in Supabase (default has rate limits)
- For development, disable email confirmation:
  - **Authentication** → **Settings** → **Email Auth** → Disable "Enable email confirmations"

### Session not persisting

- Ensure `checkAuthenticationState()` is called in `AuthenticationService.init()`
- Check that the app has keychain access permissions

---

## Next Steps

- **Task 5**: Email/password authentication is already implemented in `AuthenticationService`
- **Task 6**: Session persistence is already implemented
- **Task 7**: Implement guest mode UI and demo data

---

## Security Best Practices

1. **Never commit credentials**: Use `.gitignore` for `SupabaseConfig.swift` or use environment variables
2. **Enable Row Level Security (RLS)**: Already configured in the migration
3. **Use HTTPS**: Supabase enforces HTTPS by default
4. **Validate on backend**: Don't trust client-side validation alone
5. **Rate limiting**: Enable rate limiting in Supabase for auth endpoints
6. **Email verification**: Enable for production apps
7. **Password requirements**: Enforce strong passwords (Supabase has built-in policies)

---

## Resources

- [Supabase Swift Documentation](https://supabase.com/docs/reference/swift)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Sign in with Apple Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Apple Developer Portal](https://developer.apple.com/account/resources)
