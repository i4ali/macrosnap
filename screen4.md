# Screen 4: Settings

This screen handles goals, Pro status, and other app settings.

## "The Standard List"

This uses a classic, native iOS grouped list.

```
/--------------------------------------\
|                                      |
|  Settings                            |
|                                      |
|  [Card: Unlock MacroSnap Pro          |
|   Unlimited history, lock screen     |
|   widgets, themes & more - $4.99! >] |
|                                      |
|  ACCOUNT                             |
|  Email: user@example.com    [ > ]    |
|  (Signed in with Apple ID)           |
|  Sign Out                   [ > ]    |
|                                      |
|  (Guest Mode shows instead:)         |
|  [Banner: Create Account to Save     |
|   Your Macros & Sync Devices >]      |
|                                      |
|  GOALS                               |
|  Daily Goals                [ > ]    |
|  (sub-text: 180P, 250C, 70F)         |
|  (Pro: Set different goals per day)  |
|                                      |
|  PRO FEATURES (LOCKED 🔒)             |
|  Theme                      [Dark >] |
|  Export Data (CSV)          [ > ]    |
|                                      |
|                                      |
|  GENERAL                             |
|  Privacy Policy             [ > ]    |
|  Contact Support            [ > ]    |
|                                      |
|  (Nav Bar)                           |
|  [Today]  [History]  [Settings]      |
\--------------------------------------/
```

## Design Rationale

- **Familiar**: Instantly recognizable to any iOS user.
- **Account Management**: Shows signed-in status and provides easy access to account details and sign-out option.
- **Clear Upsell**: The Pro banner is the first item. The "Pro Features" section clearly shows what is currently locked.
- **Simple**: Easy to navigate. "Daily Goals" would lead to a simple screen with 3 number-entry fields.
- **Goals Explained**:
  - **Free**: Set one standard goal (e.g., 180P/250C/70F) that applies every day
  - **Pro**: Set different goals for different days (e.g., high carbs on training days, lower on rest days - perfect for carb cycling and training splits)
- **Sync Built-In**: All users get automatic cloud sync via Supabase - no need for a separate toggle or Pro feature
- **Guest Mode**: In guest mode, ACCOUNT section is replaced with a sign-up CTA banner. Tapping any setting shows "Create Account to Continue" prompt
