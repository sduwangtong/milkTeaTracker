# 奶茶小本 (Milk Tea Tracker)

A lightweight milk-tea tracking iOS app to log drinks in seconds, monitor sugar & calories, set monthly KPIs, and visualize consumption trends.

## 🎯 Feature Status

### ✅ Feature 1: Drink Logging (COMPLETED)
- [x] SwiftData models (Brand, DrinkTemplate, DrinkLog, CustomDrinkTemplate)
- [x] Bilingual support (English/Chinese)
- [x] Main tab navigation
- [x] Drink log main screen with popular brands
- [x] Brand selection and drink selection flow
- [x] Options sheet with size/sugar/ice pickers
- [x] Real-time calorie and sugar calculation
- [x] Quick re-log functionality
- [x] Toast notifications
- [x] Sample data seeding (6 US brands, 60 drinks)
- [x] Custom drink entry with manual nutrition input

### 🚧 Feature 2: Monthly Ledger (Planned)
- [ ] Monthly summary view
- [ ] KPI tracking
- [ ] Goal setting

### 🚧 Feature 3: Consumption Trends (Planned)
- [ ] Trend visualization
- [ ] Share capability

## 🏗️ Architecture

### SwiftData Models

**Brand** - Tea brand information
- Properties: `id`, `name`, `nameZH`, `emoji`, `isPopular`
- 6 Popular US brands: Kung Fu Tea, Gong Cha, Tiger Sugar, It's Boba Time, CoCo Fresh Tea & Juice, Nayuki

**DrinkTemplate** - Pre-defined drinks with base nutrition
- Properties: `id`, `name`, `nameZH`, `baseCalories`, `baseSugar`
- 60 drink templates (10 per brand) based on real US menus

**DrinkLog** - User's logged drinks
- Properties: `id`, `brandId`, `drinkName`, `size`, `sugarLevel`, `iceLevel`, `calories`, `sugarGrams`, `price`, `timestamp`, `isCustomDrink`

**CustomDrinkTemplate** - User-created custom drinks
- Properties: `id`, `name`, `nameZH`, `customCalories`, `customSugar`, `isCustom`, `createdDate`

**Enums**
- `DrinkSize`: small (0.8x), medium (1.0x), large (1.3x)
- `SugarLevel`: none (0x), less (0.5x), regular (1.0x), extra (1.3x)
- `IceLevel`: none, less, regular, extra

### Views Structure

```
milkTeaTrackerApp
├── MainTabView (Tab Bar)
│   ├── DrinkLogView (Tab 1) ✅
│   ├── LedgerView (Tab 2) ✅
│   └── TrendsView (Tab 3) ✅
│
└── DrinkLogView Components
    ├── BrandCard (Popular brands grid)
    ├── RecentDrinkRow (Recent drinks list)
    ├── DrinkSelectionView (Brand → Drink selection)
    └── DrinkOptionsSheet (Size/Sugar/Ice → Save)
```

## 🎨 UI Features

### Drink Logging Flow
1. **Main Screen**
   - Search bar for quick access
   - 3x2 grid of popular brands with emojis
   - Recent drinks list (last 5)
   - Language toggle (EN/中文)

2. **Brand Selection → Drink Selection**
   - Scrollable list of drinks for selected brand
   - Shows base calories for each drink
   - Search functionality

3. **Options Sheet**
   - Size picker (Small/Medium/Large)
   - Sugar level picker (None/Less/Regular/Extra)
   - Ice level picker (None/Less/Regular/Extra)
   - Optional price input
   - Real-time nutrition calculation
   - Large "Log Drink" button

4. **Quick Re-log**
   - "+" button on recent drinks
   - Creates instant duplicate with new timestamp
   - Toast confirmation

### Localization
- Bilingual: English (default) and Simplified Chinese
- Language toggle in navigation bar
- All UI elements and enums localized
- Brand names shown in both languages

## 🚀 How to Run

### Requirements
- Xcode 16+ (iOS 17+ for SwiftData)
- macOS Ventura or later

### Setup
1. Open `mikeTeaTracker.xcodeproj` in Xcode
2. Select a simulator or device (iOS 17+)
3. Build and run (⌘R)

### First Launch
- Sample data automatically seeds on first launch
- 6 popular brands with 24 drink templates
- Ready to start logging drinks immediately

## 📱 Testing the Flow

### Complete Flow Test
1. **Launch app** → See Drink Log tab with popular brands
2. **Tap "HeyTea"** → Opens drink selection sheet
3. **Tap "Grape Cheese Tea"** → Opens options sheet
4. **Select options:**
   - Size: Medium
   - Sugar: Less
   - Ice: Regular
5. **See real-time calculation:** ~160 kcal, 12.5g sugar
6. **Tap "Log Drink"** → Toast shows "✓ Logged!"
7. **View recent drinks** → New log appears at top
8. **Tap "+" on recent drink** → Quick re-log with toast

### Language Switching
1. **Tap globe icon** in navigation bar
2. **Switches between EN ↔ 中文**
3. **All text updates** instantly (brands, enums, labels)

### Quick Re-log
1. **Find any recent drink**
2. **Tap "+" button** on the right
3. **Toast appears** confirming log
4. **List updates** with new timestamp

## 📂 Project Structure

```
mikeTeaTracker/
├── Models/
│   ├── Brand.swift
│   ├── DrinkTemplate.swift
│   ├── DrinkLog.swift
│   └── DrinkSize.swift (Enums)
├── Views/
│   ├── MainTabView.swift
│   ├── DrinkLog/
│   │   ├── DrinkLogView.swift
│   │   ├── DrinkSelectionView.swift
│   │   └── DrinkOptionsSheet.swift
│   └── Components/
│       ├── BrandCard.swift
│       └── RecentDrinkRow.swift
├── Helpers/
│   ├── LanguageManager.swift
│   └── ToastManager.swift
├── Data/
│   └── SampleData.swift
├── Localizable.xcstrings
└── Assets.xcassets/
```

## 🎯 Success Metrics (from BRD)

- [x] User can log a drink in **≤3 seconds** (brand → drink → log)
- [x] Recent drinks show correct: name, brand, size, sugar, calories
- [x] Quick re-log "+" button creates instant duplicate
- [x] Nutrition auto-calculated correctly
- [x] Toast confirmation (no blocking modal)
- [x] Bilingual UI switches correctly

## 🔧 Technical Details

### Data Persistence
- **SwiftData** for local-only storage
- **Automatic seeding** on first launch
- **Offline-first** architecture

### Calculations
```swift
calories = baseCalories × sizeMultiplier × sugarMultiplier
sugar = baseSugar × sizeMultiplier × sugarMultiplier
```

### Performance Optimizations
- `@Query` with limits for recent drinks
- `LazyVGrid` for brand grid
- Efficient SwiftData relationships
- Toast auto-dismiss (1.5s)

## 📝 Sample Data (Based on Real US Menus)

### Brands (6 Top US Chains)
1. 🥋 Kung Fu Tea (功夫茶) - 350+ locations, largest US chain
2. 🏆 Gong Cha (贡茶) - 150 locations, premium quality
3. 🐯 Tiger Sugar (老虎堂) - Famous for brown sugar boba
4. ⏰ It's Boba Time (波霸时光) - 95 locations, LA-based
5. 🥥 CoCo Fresh Tea & Juice (都可) - International chain, known for customization
6. 🧋 Nayuki (奈雪的茶) - Known for cheese tea series

### Example Drinks (60 Total)
- Kung Fu Milk Tea (280 kcal, 23g sugar)
- Brown Sugar Boba Milk - Tiger Sugar (450 kcal, 54g sugar)
- Taro Milk Tea (370-390 kcal, 31-33g sugar)
- Matcha Milk Tea (300-320 kcal, 24-26g sugar)
- Bubble Milk Tea - CoCo Fresh Tea & Juice (388 kcal, 28g sugar)
- Strawberry Cheese - Nayuki (450 kcal, 35g sugar)
- *...and 54 more authentic drinks*

### Custom Drinks
- Users can create unlimited custom drinks
- Manual calorie and sugar input
- Full size/sugar/ice customization
- Saved for quick re-logging

## 🚧 Next Steps

### Feature 2: Monthly Ledger
- Monthly summary with cups/calories/spend
- KPI tracking and goal setting
- Daily breakdown view

### Feature 3: Trends
- Visual trend charts
- Category breakdown by brand
- Shareable summary cards

## 📄 License

Private project for Mike's tea tracking needs.

---

**Built with:** SwiftUI, SwiftData, iOS 17+
**Status:** Feature 1 (Drink Logging) ✅ Complete
