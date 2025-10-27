# Privacy Policy Hosting Guide

Your privacy policy is ready! Now you need to host it at a public URL for App Store submission.

## Files Created

- `PRIVACY_POLICY.md` - Markdown version for documentation
- `privacy.html` - HTML version ready to host

---

## Hosting Option 1: GitHub Pages (Recommended - FREE & Fast)

**Best for:** Quick setup, no domain required

### Steps:

1. **Create a new GitHub repository** (or use existing)
   ```bash
   # In your macrosnap directory
   git add privacy.html
   git commit -m "Add privacy policy"
   git push
   ```

2. **Enable GitHub Pages:**
   - Go to your repo: https://github.com/i4ali/macrosnap
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: `main` → `/` (root)
   - Click Save

3. **Your URL will be:**
   ```
   https://i4ali.github.io/macrosnap/privacy.html
   ```

4. **Wait 2-5 minutes** for deployment, then test the URL

✅ **Use this URL in App Store Connect**

---

## Hosting Option 2: Custom Domain (If You Own One)

**Best for:** Professional appearance

If you own `macrosnap.app`:

### Option 2A: Simple Hosting (Netlify - FREE)

1. **Sign up at https://netlify.com**
2. **Drag & drop** the `privacy.html` file
3. **Set custom domain:** macrosnap.app
4. **Your URL:** `https://macrosnap.app/privacy.html`

### Option 2B: GitHub Pages + Custom Domain

1. Follow Option 1 (GitHub Pages)
2. In repo Settings → Pages → Custom domain
3. Enter: `macrosnap.app`
4. Add CNAME record in your DNS:
   ```
   CNAME  @  i4ali.github.io
   ```
5. **Your URL:** `https://macrosnap.app/privacy.html`

---

## Hosting Option 3: Vercel (FREE)

**Best for:** Modern deployment, instant updates

1. **Sign up at https://vercel.com**
2. **Import your GitHub repo**
3. **Deploy** (automatic)
4. **Your URL:** `https://macrosnap.vercel.app/privacy.html`

Or with custom domain:
5. Add domain in Vercel settings
6. **Your URL:** `https://macrosnap.app/privacy.html`

---

## Hosting Option 4: Simple Static Host

**Other free options:**
- **Netlify:** https://netlify.com (drag & drop)
- **Surge.sh:** https://surge.sh (CLI-based)
- **Cloudflare Pages:** https://pages.cloudflare.com

---

## Quick Start (Recommended Path)

### For GitHub Pages (Easiest):

```bash
# Make sure privacy.html is in your repo root
git add privacy.html PRIVACY_POLICY.md
git commit -m "Add privacy policy for App Store"
git push

# Then enable GitHub Pages in repo settings
```

**Your privacy URL will be:**
```
https://i4ali.github.io/macrosnap/privacy.html
```

---

## After Hosting

### Test Your URL:
1. Open the URL in a browser
2. Verify the page loads correctly
3. Check it works on mobile Safari

### Use in App Store Connect:
- **Privacy Policy URL:** Your hosted URL
- **Example:** `https://i4ali.github.io/macrosnap/privacy.html`

---

## Domain Purchase (Optional)

If you want `macrosnap.app`:

**Registrars:**
- **Namecheap:** ~$12-15/year
- **Google Domains:** ~$12/year
- **Cloudflare:** ~$10/year (cheapest)

Then use Option 2A or 2B to host with custom domain.

---

## What Apple Requires

✅ Privacy policy must be:
- Publicly accessible
- No login required
- HTTPS (secure)
- Mobile-friendly
- Always available

All hosting options above meet these requirements!

---

## Support Page (Bonus)

You'll also need a support page. Create `support.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Support - MacroSnap</title>
    <style>
        body {
            font-family: -apple-system, sans-serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            line-height: 1.6;
        }
        h1 { color: #1d1d1f; }
    </style>
</head>
<body>
    <h1>MacroSnap Support</h1>
    <p>Need help? We're here for you!</p>

    <h2>Contact</h2>
    <p>Email: <a href="mailto:support@macrosnap.app">support@macrosnap.app</a></p>

    <h2>FAQ</h2>
    <h3>How do I sync my data?</h3>
    <p>MacroSnap automatically syncs via iCloud. Make sure iCloud is enabled.</p>

    <h3>How do I restore Pro features?</h3>
    <p>Go to Settings → Tap "Restore Purchases"</p>

    <h3>How do I delete my data?</h3>
    <p>Delete the app, then go to Settings → iCloud → Manage Storage → MacroSnap → Delete Data</p>
</body>
</html>
```

Then host this too for your support URL!

---

## Recommended Next Steps

1. ✅ **Host privacy.html on GitHub Pages** (5 minutes)
2. ✅ **Test the URL** works
3. ✅ **Copy URL** for App Store Connect
4. ⏳ **Consider buying domain** (optional, later)

---

**Need help?** Let me know which hosting option you prefer and I can guide you through the specific steps!
