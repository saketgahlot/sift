# Sift - Smart Recycling Assistant

<div align="center">

**Scan to Sort. Reduce Contamination. Recycle Right.**

[![iOS](https://img.shields.io/badge/iOS-15.0+-000000?style=flat&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat&logo=swift&logoColor=white)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#features) • [Demo](#demo) • [Installation](#installation) • [Usage](#usage) • [Architecture](#architecture) • [Roadmap](#roadmap)

</div>

---

## 📱 About

**Sift** is an iOS app that uses machine learning to help users determine whether items are recyclable or trash. Unlike other recycling apps, Sift focuses on **reducing contamination rates** in recycling systems through:

- Real-time AR scanning for instant classification
- Low-confidence warnings to prevent uncertain items from contaminating recycling
- Proactive recycling day reminders to build consistent habits
- Clean, minimalist interface designed for quick decisions

### 🎯 Mission

Reduce recycling contamination rates by empowering everyday people with instant, accurate recyclability information and smart reminders.

---

## ✨ Features

### 🔍 Smart Classification
- **Photo Classification** - Take a photo or upload from library
- **AR Real-Time Scanning** - Point and scan items instantly
- **Confidence Scoring** - See how certain the model is about each classification
- **Binary Classification** - Clear recyclable vs. trash results

### ⚠️ Contamination Prevention
- **Low Confidence Warnings** - When model confidence is below 60%, shows "If in doubt, throw it out"
- **Mission-Driven Design** - Prioritizes recycling quality over quantity
- **Educational Approach** - Helps users understand when to be cautious

### 📅 Habit Building
- **Recycling Day Reminders** - Select your recycling days during onboarding
- **Smart Notifications** - Get reminded the day before at 7 PM
- **Multi-Day Support** - Perfect for areas with different recycling schedules

### ⚙️ User Control
- **Settings Page** - Easy access via gear icon in top-right corner
- **Update Schedule Anytime** - Change your recycling days whenever needed
- **Notification Management** - Full control over reminders

### 🎨 Design
- **Minimalist Interface** - Clean, monospaced typography with black and white aesthetic
- **Smooth Scrolling** - Fixed header with scrollable content
- **Accessibility** - Clear visual hierarchy and readable fonts
- **Responsive** - Works on all iPhone sizes

---

## 🖼️ Demo

### Screenshots

<div align="center">

| Onboarding | Main Screen | AR Scan Mode | Settings |
|:----------:|:-----------:|:------------:|:--------:|
| ![Onboarding](screenshots/onboarding.png) | ![Main](screenshots/main.png) | ![AR Mode](screenshots/ar.png) | ![Settings](screenshots/settings.png) |

| Photo Classification | Low Confidence Warning |
|:-------------------:|:---------------------:|
| ![Classification](screenshots/classification.png) | ![Warning](screenshots/warning.png) |

</div>

> **Note:** Add your screenshots to the `screenshots/` directory

---

## 🚀 Installation

### Prerequisites

- **Xcode 15.0+**
- **iOS 15.0+** deployment target
- **Swift 5.9+**
- Physical iPhone device (for AR features and camera)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/sift.git
   cd sift
   ```

2. **Open in Xcode**
   ```bash
   open Sift.xcodeproj
   ```

3. **Configure Signing**
   - Select your project in the navigator
   - Choose your target
   - Go to "Signing & Capabilities"
   - Select your development team

4. **Add Required Capabilities**
   - Click "+ Capability"
   - Add "Push Notifications"
   - Add "Background Modes" and enable "Remote notifications"

5. **Configure Info.plist**
   
   Add these privacy descriptions:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to scan items for recyclability</string>
   
   <key>NSLocalNetworkUsageDescription</key>
   <string>To provide you with recycling reminders</string>
   ```

6. **Build and Run**
   - Select a physical device (AR requires real device)
   - Press `Cmd + R` to build and run

---

## 📖 Usage

### First Launch
1. Select your recycling days from the welcome screen
2. Grant notification permissions when prompted
3. Start scanning items!

### Scanning Items
**Photo Mode:**
1. Tap "CAMERA" or "PHOTOS" button
2. Take/select a photo of the item
3. Tap "CLASSIFY" to see results

**AR Mode:**
1. Tap "AR SCAN MODE" button
2. Point camera at item
3. Aim the center reticle at the item
4. Results appear in real-time

### Managing Settings
1. Tap the gear icon (⚙️) in top-right corner
2. Select/deselect recycling days
3. Tap "SAVE CHANGES"
4. Notifications automatically update

---

## 🏗️ Architecture

### Tech Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI
- **ML Framework:** Core ML + Vision
- **Camera:** AVFoundation
- **Notifications:** UserNotifications
- **Storage:** @AppStorage (UserDefaults)
- **Location:** CoreLocation (future feature)

### Project Structure

```
Sift/
├── SiftApp.swift              # App entry point
├── Views/
│   ├── ContentView.swift      # Main screen with photo classification
│   ├── OnboardingView.swift   # First-launch welcome screen
│   ├── ARScanView.swift       # Real-time AR scanning mode
│   └── SettingsView.swift     # Recycling day management
├── Components/
│   └── ImagePicker.swift      # UIKit camera/photo picker bridge
├── Managers/
│   └── NotificationManager.swift  # Notification scheduling
├── Models/
│   └── SiftModel.mlmodel      # Core ML classification model
└── Assets.xcassets/
```

### Key Components

**ContentView**
- Main hub with three scanning options
- Photo classification with confidence display
- Low confidence warnings for recyclable items
- Settings access via gear icon

**ARScanView**
- Real-time camera feed using AVFoundation
- Continuous ML classification (throttled to 0.5s intervals)
- Floating overlay with results
- Battery-efficient implementation

**OnboardingView**
- First-run experience
- Day selection for recycling schedule
- Notification permission request
- Saves preferences via @AppStorage

**SettingsView**
- Update recycling days anytime
- Syncs with notification schedule
- Save confirmation feedback
- Loads current selections on open

**NotificationManager**
- Schedules weekly notifications
- Triggers day before recycling at 7 PM
- Handles permission requests
- Updates/removes notifications dynamically

---

## 🧠 Machine Learning Model

### Model Details
- **Type:** Image Classification
- **Framework:** Core ML
- **Architecture:** Binary classifier (Recyclable vs. Trash)
- **Output:** Class label + confidence score
- **Input:** Image (any size, preprocessed internally)

### Classification Logic
```swift
if confidence >= 0.6 && isRecyclable:
    ✓ Show "RECYCLABLE"
elif confidence < 0.6 && isRecyclable:
    ⚠️ Show "RECYCLABLE" + "IF IN DOUBT, THROW IT OUT"
else:
    ✗ Show "TRASH"
```

### Model Training
*Details about your model training process, dataset, and accuracy metrics can be added here*

---

## 🎨 Design Philosophy

### Visual Identity
- **Minimalist:** Clean, distraction-free interface
- **Monospaced Typography:** Technical, precise aesthetic
- **Black & White:** Focus on information, not decoration
- **Generous Spacing:** Easy to read and navigate

### Color Coding
- **Green:** Recyclable items
- **Red:** Trash items
- **Orange:** Low confidence warnings
- **Black/White:** Primary UI elements

### UX Principles
1. **Speed:** Results in seconds, not minutes
2. **Clarity:** Binary decisions, clear outcomes
3. **Safety:** Warns when uncertain
4. **Habit-Building:** Reminders drive consistent behavior

---

## 🔮 Roadmap

### Version 2.0 (Planned)
- [ ] Scan history with search
- [ ] Impact tracking (items scanned, contamination prevented)
- [ ] Daily/weekly scan streaks
- [ ] Educational "Why?" explainers

### Version 3.0 (Future)
- [ ] Location-based recycling rules
- [ ] Material type identification
- [ ] Community verification system
- [ ] Pre-purchase shopping scanner
- [ ] Barcode database integration

### Long-term Vision
- [ ] Multi-object AR detection
- [ ] Integration with local waste services
- [ ] Social challenges and leaderboards
- [ ] AI recycling coach
- [ ] Alternative disposal route suggestions

---

## 🤝 Contributing

Contributions are welcome! Whether it's bug fixes, feature additions, or documentation improvements.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines
- Follow Swift style guide
- Maintain SwiftUI best practices
- Keep the minimalist design aesthetic
- Add comments for complex logic
- Test on multiple device sizes

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- ML powered by [Core ML](https://developer.apple.com/machine-learning/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)

---

## 📧 Contact

**Saket Gahlot**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

**Project Link:** [https://github.com/yourusername/sift](https://github.com/yourusername/sift)

---

## 📊 Stats

![GitHub stars](https://img.shields.io/github/stars/yourusername/sift?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/sift?style=social)
![GitHub issues](https://img.shields.io/github/issues/yourusername/sift)
![GitHub pull requests](https://img.shields.io/github/issues-pr/yourusername/sift)

---

<div align="center">

**Made with ♻️ by Saket Gahlot**

*Reducing contamination, one scan at a time.*

[⬆ Back to Top](#sift---smart-recycling-assistant)

</div>
