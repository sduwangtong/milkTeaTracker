# Backend Setup Guide

This guide walks you through setting up the backend services for Milk Tea Tracker.

## Quick Start

The app works locally without any backend configuration. All features below are optional enhancements.

---

## Feature 1: Simple Drink Logger (Google Sheets)

Log all drinks to a Google Sheet for data analysis.

### Step 1: Create the Google Sheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new blank spreadsheet
3. Rename it to "MilkTeaTracker Drink Logs"

The script will automatically create the sheet with headers when first used.

### Step 2: Deploy the Apps Script

1. In your Google Sheet, go to **Extensions > Apps Script**
2. Delete any existing code in `Code.gs`
3. Copy the entire contents of `SimpleDrinkLogger.js`
4. Paste it into the Apps Script editor
5. **Important:** Change the `API_KEY` constant to a secure random string:
   ```javascript
   const API_KEY = 'your-secure-random-key-here';
   ```
   Generate one at: https://randomkeygen.com/ (use "CodeIgniter Encryption Keys")
6. Save the project (Ctrl/Cmd + S)

### Step 3: Deploy as Web App

1. Click **Deploy > New deployment**
2. Click the gear icon and choose **Web app**
3. Configure:
   - Description: "Simple Drink Logger v1"
   - Execute as: **Me**
   - Who has access: **Anyone**
4. Click **Deploy**
5. **Copy the Web App URL**

### Step 4: Configure iOS App

Update `AuthConfig.swift`:

```swift
static let simpleSheetsURL = "YOUR_WEB_APP_URL_HERE"
static let sheetsAPIKey = "your-secure-random-key-here"  // Must match API_KEY in Apps Script
```

### Test the Setup

```bash
# Test ping
curl "YOUR_WEB_APP_URL?action=ping"

# Test logging a drink (include your API key)
curl -X POST "YOUR_WEB_APP_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "apiKey": "your-secure-random-key-here",
    "email": "test@example.com",
    "name": "Test User",
    "brandName": "CoCo",
    "drinkName": "Pearl Milk Tea",
    "size": "medium",
    "sugarLevel": "regular",
    "iceLevel": "regular",
    "calories": 350,
    "sugarGrams": 40
  }'
```

**Note:** Requests without the correct API key will be rejected with a 401 error.

---

## Feature 2: Google Sign-In

### Step 1: Google Cloud Console Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable **Google Sign-In API**
4. Go to **Credentials > Create Credentials > OAuth 2.0 Client IDs**
5. Select **iOS** application type
6. Enter your Bundle ID: `com.yourcompany.milkTeaTracker`
7. Copy the **Client ID**

### Step 2: Add to Xcode Project

1. Add `GoogleSignIn` Swift Package:
   - URL: `https://github.com/google/GoogleSignIn-iOS`
   - Version: 7.0.0 or later

2. Add URL Scheme to Info.plist:
   - URL Schemes: Your reversed client ID (e.g., `com.googleusercontent.apps.YOUR_CLIENT_ID`)

### Step 3: Configure iOS App

Update `AuthConfig.swift`:

```swift
static let googleClientID = "YOUR_CLIENT_ID.apps.googleusercontent.com"
```

---

## Feature 3: Google AdMob

### Step 1: AdMob Setup

1. Go to [AdMob](https://admob.google.com)
2. Create an account or sign in
3. Add a new iOS app
4. Create a **Banner** ad unit
5. Copy the **App ID** and **Ad Unit ID**

### Step 2: Add to Xcode Project

1. Add `GoogleMobileAds` Swift Package:
   - URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
   - Version: 11.0.0 or later

2. Add to Info.plist:
```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_ADMOB_APP_ID</string>
<key>SKAdNetworkItems</key>
<array>
  <!-- Add SKAdNetwork IDs from Google's documentation -->
</array>
```

### Step 3: Configure iOS App

Update `AuthConfig.swift`:

```swift
static let adMobAppID = "YOUR_ADMOB_APP_ID"
static let bannerAdUnitID = "YOUR_BANNER_AD_UNIT_ID"
```

### Testing

During development, the app automatically uses test ad unit IDs. You'll see test ads labeled "Test Ad".

---

## Feature Flags

Control feature visibility in `FeatureFlags.swift`:

```swift
struct FeatureFlags {
    static let showPopularBrands = false  // Brand selection UI
    static let showTrends = false         // Trends tab
    static let showAds = true             // AdMob ads
}
```

---

## Schema Reference

### Drink Log Schema (Google Sheets)

| Column | Type | Description |
|--------|------|-------------|
| email | String | User's email address |
| name | String | User's display name |
| brandName | String | Brand name (English) |
| brandNameZH | String | Brand name (Chinese) |
| drinkName | String | Drink name (English) |
| drinkNameZH | String | Drink name (Chinese) |
| size | String | small/medium/large |
| sugarLevel | String | none/less/regular/extra |
| iceLevel | String | none/less/regular/extra |
| bubbleLevel | String | none/regular/extra |
| calories | Number | Estimated calories |
| sugarGrams | Number | Estimated sugar (grams) |
| price | Number | Price paid (optional) |
| timestamp | ISO8601 | When the drink was logged |
| isCustomDrink | Boolean | Whether it's a custom entry |
| latitude | Number | GPS latitude (optional) |
| longitude | Number | GPS longitude (optional) |
| syncedAt | ISO8601 | When synced to sheet |
| isDeleted | Boolean | Soft delete flag |

---

## Troubleshooting

### Drinks not logging to Sheets
1. Check that `simpleSheetsURL` is configured in `AuthConfig.swift`
2. Verify the Apps Script is deployed as "Anyone" access
3. Check Xcode console for `[DrinkLogger]` messages

### Google Sign-In not working
1. Verify the Client ID is correct
2. Check URL scheme is added to Info.plist
3. Ensure bundle ID matches Google Cloud Console

### Ads not showing
1. Verify AdMob App ID in Info.plist
2. Check that `FeatureFlags.showAds = true`
3. Wait a few minutes - test ads may take time to load
