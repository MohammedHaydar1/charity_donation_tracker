# 🫶 Charity Donation Tracker

A feature-rich Flutter Android app to track your charitable donations, manage charities, visualize spending analytics, and stay on top of your monthly giving goals — all stored locally with SQLite.

---

## 📱 Screenshots

> Run the app and take screenshots, then add them here.

---

## ✨ Features

- **Dashboard** — total donated all-time, monthly goal progress, recent donations
- **Donation Management** — add, edit, delete donations with full details
- **Charity Management** — create and manage multiple charities with colors and categories
- **Analytics** — bar chart (12-month history), pie chart by category, per-category breakdown
- **Monthly Budget Goal** — set a goal and track progress with a live progress bar
- **Recurring Donations** — mark donations as weekly / monthly / quarterly / yearly
- **Payment Methods** — Cash, Credit Card, Bank Transfer, Crypto, Cheque, Online
- **Search & Filter** — search by name or note, filter by category
- **Dark Mode** — full light/dark theme support following system setting
- **Local SQLite database** — no internet required, all data stays on device

---

## 🗂️ Project Structure

```
lib/
├── main.dart                        # App entry point
├── app_theme.dart                   # Colors, themes, categories, icons
├── database/
│   └── db_helper.dart               # SQLite setup and all queries
├── models/
│   ├── donation.dart                # Donation data model
│   ├── charity.dart                 # Charity data model
│   └── budget_goal.dart             # Monthly goal data model
├── providers/
│   └── app_provider.dart            # State management (Provider)
├── screens/
│   ├── home_screen.dart             # Dashboard + bottom navigation
│   ├── donations_screen.dart        # Donations list with search/filter
│   ├── charities_screen.dart        # Charities list and management
│   ├── analytics_screen.dart        # Charts and statistics
│   ├── add_edit_donation_screen.dart
│   └── add_edit_charity_screen.dart
└── widgets/
    ├── donation_card.dart
    ├── charity_avatar.dart
    ├── stat_card.dart
    ├── category_bar.dart
    └── monthly_chart.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.4.0`
- Android Studio or VS Code
- Android device or emulator (API 21+)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/charity_donation_tracker.git
cd charity_donation_tracker

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run --no-enable-impeller
```

---

## 🔧 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.3.3 | Local SQLite database |
| `path` | ^1.9.0 | Database file path |
| `intl` | ^0.19.0 | Date formatting |
| `provider` | ^6.1.2 | State management |
| `fl_chart` | ^0.68.0 | Bar and pie charts |
| `share_plus` | ^9.0.0 | Export/share donations |
| `path_provider` | ^2.1.3 | File system access |
| `csv` | ^6.0.0 | CSV export |

---

## 📦 Building the APK

### Debug APK (for testing)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (for distribution)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Split APKs by ABI (smaller file size — recommended)

```bash
flutter build apk --split-per-abi --release
```

Output (3 files, pick the right one for your device):
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk    ← modern phones
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk  ← older phones
build/app/outputs/flutter-apk/app-x86_64-release.apk       ← emulator
```

> For most modern Android phones, use `app-arm64-v8a-release.apk`.

---

## 📲 How to Install the APK on Your Phone

### Method 1 — USB (recommended)

1. Enable **Developer Options** on your phone:
   > Settings → About Phone → tap **Build Number** 7 times
2. Enable **USB Debugging**:
   > Settings → Developer Options → USB Debugging → ON
3. Connect phone via USB and run:
   ```bash
   flutter install
   ```
   or directly install the APK:
   ```bash
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

### Method 2 — File Transfer

1. Build the release APK (see above)
2. Copy the `.apk` file to your phone via USB, Google Drive, WhatsApp, email, etc.
3. On your phone go to:
   > Settings → Security → **Install Unknown Apps** → allow your file manager
4. Open the APK file on your phone and tap **Install**

### Method 3 — Direct run on connected device

```bash
flutter run --release --no-enable-impeller
```

---

## 🔑 Release Signing (required for Play Store)

If you want to publish to Google Play or share a properly signed APK:

### 1. Generate a keystore

```bash
keytool -genkey -v -keystore charity_tracker.jks -keyalg RSA -keysize 2048 -validity 10000 -alias charity
```

### 2. Create `android/key.properties`

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=charity
storeFile=../charity_tracker.jks
```

### 3. Update `android/app/build.gradle`

Add before `android {`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Inside `android { ... }` replace `buildTypes` with:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled false
        shrinkResources false
    }
}
```

### 4. Build signed APK

```bash
flutter build apk --release
```

---

## 🗄️ Database Schema

```sql
-- Charities
CREATE TABLE charities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  website TEXT,
  colorValue INTEGER NOT NULL,
  createdAt TEXT NOT NULL
);

-- Donations
CREATE TABLE donations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  charityId INTEGER NOT NULL,
  charityName TEXT NOT NULL,
  amount REAL NOT NULL,
  category TEXT NOT NULL,
  date TEXT NOT NULL,
  note TEXT,
  isRecurring INTEGER DEFAULT 0,
  recurringInterval TEXT,
  paymentMethod TEXT DEFAULT 'Cash',
  FOREIGN KEY (charityId) REFERENCES charities(id) ON DELETE CASCADE
);

-- Monthly Goals
CREATE TABLE budget_goals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  goalAmount REAL NOT NULL,
  UNIQUE(year, month)
);
```

---

## 📋 Categories Supported

Education · Health · Environment · Food · Shelter · Children · Animals · Disaster Relief · Human Rights · Other

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

## 👤 Author

Built with Flutter & ❤️ for tracking charitable giving.