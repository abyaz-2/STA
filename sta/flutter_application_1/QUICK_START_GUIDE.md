# 🚀 Quick Start Guide - Subscription Tracking App

## Prerequisites

- Flutter 3.9.2+ installed
- Dart 3.9.2+
- Android SDK 21+ OR XCode 11+
- 2GB RAM minimum

## Installation & Setup

### 1. Get Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
# Development mode
flutter run

# Specific device
flutter run -d chrome          # Web
flutter run -d emulator-5554   # Android
flutter run -d iPhone          # iOS
```

### 3. Test the Build
```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Preview on web
flutter run -d chrome
```

---

## 📱 First Time User Steps

**Demo Flow (No Password Required):**

1. **App Launches** → Login Screen
2. **Sign Up:**
   - Email: `user@example.com`
   - Name: `Your Name`
   - Tap "Sign Up"
3. **View Dashboard** → See empty state
4. **Add Subscription:**
   - Go to "Subs" tab
   - Tap + button
   - Enter details:
     - Name: `Netflix`
     - Amount: `15.99`
     - Cycle: `Monthly`
   - Select Category: `Streaming`
   - Set Reminder: `3 days`
   - Pick Date: 30 days from today
   - Tap "Save Subscription"
5. **View on Dashboard** → See monthly spend updated
6. **View Analytics** → See category breakdown
7. **Create Group:**
   - Go to "Groups" tab
   - Create group "My Group"
   - Invite a friend with email
8. **View Profile** → Tap avatar in top-right
   - Edit name
   - Logout

---

## 🎯 Key Features Demo

### Add Subscription with Category
```
Subscriptions → Add (+)
├─ Name: Spotify
├─ Amount: 9.99
├─ Cycle: Monthly  
├─ Category: Music (🎵)
├─ Reminder: 7 days
├─ Date: 2026-05-01
└─ Save → Shows green Music badge
```

### Create Custom Category
```
Categories Screen
├─ Tap "Create Custom"
├─ Name: Gaming
├─ Color: Pick vibrant color
├─ Icon: videogame_asset
└─ Save → Use in subscriptions
```

### Send Group Invite
```
Groups → Select Group
├─ Tap "Invite Member"
├─ Enter: friend@example.com
├─ Send → Gets unique code (e.g., "ABC123")
├─ Share code or deep link
└─ Friend accepts/rejects
```

### View Analytics
```
Analytics Tab
├─ See pie chart of category spending
├─ View category-wise breakdown
├─ Check monthly projections
└─ See which category costs most
```

---

## 🔧 Development Commands

### Common Tasks

```bash
# Format code
dart format lib/

# Run analyzer
flutter analyze

# Run on specific device
flutter run -d <device_id>

# Build for production
flutter build apk --release        # Android
flutter build appbundle --release  # Google Play
flutter build ios --release        # iOS

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Device logs
flutter logs
```

### Debugging

```bash
# Enable verbose logging
flutter run -v

# Attach debugger to running app
flutter attach

# Debug breakpoints in IDE
# Set breakpoints and in VS Code: F5 or Run → Start Debugging
```

---

## 📁 File Structure Quick Reference

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data structures
│   ├── user.dart               # User model
│   ├── subscription.dart       # Subscription model
│   ├── category.dart           # Category model
│   ├── group.dart              # Group model
│   └── invite.dart             # Invite model
│
├── services/                    # Business logic
│   ├── storage_service.dart    # Data persistence
│   ├── profile_service.dart    # User management
│   ├── category_service.dart   # Categories
│   ├── invite_service.dart     # Invitations
│   └── notification_service.dart # Reminders
│
├── screens/                     # UI Screens
│   ├── login_signup_screen.dart
│   ├── home_screen.dart
│   ├── profile_screen.dart
│   ├── add_subscription_screen.dart
│   └── subscription_detail_screen.dart
│
├── features/                    # Feature modules
│   ├── dashboard/
│   ├── subscriptions/
│   ├── categories/
│   ├── groups/
│   ├── analytics/
│   └── invites/
│
├── widgets/                     # Reusable components
│   └── subscription_tile.dart
│
└── theme/
    └── app_theme.dart
```

---

## 💡 Common Issues & Solutions

### Issue: "Hive box not initialized"
**Solution:** Ensure `StorageService.init()` is called in `main()` before accessing data

### Issue: "Port 8080 already in use"
**Solution:** Change port with `flutter run -d web --web-port 8181`

### Issue: "BuildContext used after async gap"
**Solution:** Check if widget is mounted: `if (!mounted) return;` before using context

### Issue: "Can't find category colors"
**Solution:** Ensure CategoryService is initialized in main()

### Issue: "Notification not showing"
**Solution:** 
- Android: Check notification channel and permissions
- iOS: Check app permissions in Settings → Notifications

---

## 🎨 Customization Tips

### Change Theme Colors
Edit `lib/main.dart`:
```dart
const seedColor = Color(0xFF8BC34A);  // Change this
// All colors automatically regenerate
```

### Add New Category
Edit `lib/services/category_service.dart`:
```dart
Category(
  name: 'Gaming',
  color: '#FF33FF',
  icon: 'videogame_asset',
  userId: 'system',
  isDefault: true,
)
```

### Modify Dashboard Layout
Edit `lib/features/dashboard/dashboard_screen.dart`:
- Change card heights
- Modify chart types
- Add new widgets

---

## 📊 Performance Tips

1. **Images:** Use WebP instead of PNG
2. **Animations:** Keep duration < 500ms
3. **Lists:** Use `ListView.builder()` for large lists
4. **State Management:** Use `setState()` for simple, `Riverpod` for complex
5. **Database:** Index frequently queried fields

---

## 🔐 Building Secure APK

```bash
# Create keystore
keytool -genkey -v -keystore ~/key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 -alias key

# Build signed APK
flutter build apk --release \
  --keystore ~/key.jks \
  --keystore-password yourpassword \
  --key-password keypassword \
  --key-alias key
```

---

## 📱 Testing on Physical Device

### Android
```bash
# Enable developer mode
# Settings → About Phone → Build Number (tap 7x)
# Go back → Developer Options → USB Debugging ON

# Connect via USB, then:
flutter devices
flutter run -d <device>
```

### iOS
```bash
# Connect device via USB
# Trust computer when prompted
# Then:
flutter run -d all  # Installs on all devices
```

---

## 🚀 Deployment

### Android (Google Play)
1. Build appbundle: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Create release, add notes
4. Submit for review (1-3 hours)

### iOS (Apple App Store)
1. Build: `flutter build ios --release`
2. Open in Xcode: `open ios/Runner.xcworkspace`
3. Sign with developer certificate
4. Upload to App Store Connect
5. Submit for review (24-48 hours)

### Web
```bash
flutter build web --release
# Outputs to build/web/
# Deploy to any web server (Firebase Hosting, Netlify, etc.)
```

---

## 📚 Useful Resources

- **Flutter Docs:** https://flutter.dev/docs
- **Dart Language:** https://dart.dev/guides
- **Material Design:** https://material.io/design
- **Hive Database:** https://docs.hivedb.dev
- **Flutter Riverpod:** https://riverpod.dev

---

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Make changes
3. Run: `flutter test && flutter analyze`
4. Commit: `git commit -am 'Add feature'`
5. Push:  `git push origin feature/your-feature`
6. Create Pull Request

---

## 📞 Support

- Check documentation files in project root
- Review example code in `lib/`
- Check Flutter docs at flutter.dev
- Ask in Flutter community

---

## ✨ Quick Feature Requests

| Feature | Where | How |
|---------|-------|-----|
| Add Budget Alerts | `dashboard_screen.dart` | Add threshold check |
| Export to CSV | `analytics_screen.dart` | Add export button |
| Dark Mode | `app_theme.dart` | Add dark theme |
| Multi-Currency | `subscription_detail_screen.dart` | Add currency picker |
| Yearly View | New screen | Add year selector |

---

**Happy Coding! 🎉**

Need help? Check COMPLETE_FEATURE_SUMMARY.md or IMPLEMENTATION_COMPLETE.md for full documentation.
