# SIFT — Scan to Sort

**Sift** is a minimalist iOS app that tells you whether an item is recyclable or trash — snap a photo, and it sorts it for you. It also reminds you the day before your recycling pickup.

> *If in doubt, throw it out.* Sift warns you when confidence is low, because a questionable item in the recycling bin can contaminate the whole load.

## Features

- 📷 **Photo classification** — Capture an image with the camera or pick one from your photo library, then classify it on-device.
- ♻️ **Recyclable vs. Trash** — A Core ML model labels the item `RECYCLABLE` or `TRASH` and shows a confidence percentage.
- ⚠️ **Low-confidence warning** — If a recyclable prediction has less than 60% confidence, Sift advises you to play it safe and throw it out.
- 🔔 **Recycling day reminders** — Choose which days your recycling is collected and get a 7 PM push notification the day before each one.
- 🚀 **Onboarding** — A first-launch flow sets up your recycling days and notification permissions (skippable).

Everything runs **on-device** — no accounts, no network requests, no data collection.

## How it works

1. Open the app and take or choose a photo of an item.
2. Tap **CLASSIFY**.
3. Vision (`VNCoreMLRequest`) runs the bundled `SiftModel.mlmodel` over the image and returns the top prediction.
4. Sift displays the verdict, the confidence score, and an appropriate nudge.

Recycling-day selections are persisted locally via `@AppStorage`, and `UNUserNotificationCenter` schedules repeating reminders for each selected day.

## Tech stack

| Area | Technology |
| --- | --- |
| UI | SwiftUI |
| Image classification | Core ML + Vision (`SiftModel.mlmodel`) |
| Camera / photo library | `UIImagePickerController` via `UIViewControllerRepresentable` |
| Notifications | `UserNotifications` (repeating calendar triggers) |
| Persistence | `@AppStorage` (UserDefaults) |
| Deployment target | iOS 26.0, iPhone & iPad |

## Project structure

```
Sift/
├── SiftApp.swift            # Entry point, onboarding gate
├── ContentView.swift        # Main screen: capture, classify, results
├── OnboardingView.swift     # First-run recycling-day setup
├── SettingsView.swift       # Update recycling days
├── NotificationManager.swift# Schedule/clear pickup reminders
├── ImagePicker.swift        # Camera & photo library wrapper
├── SiftModel.mlmodel        # On-device classifier
└── Assets.xcassets          # App icon & colors
```

## Getting started

1. Clone the repository:
   ```bash
   git clone git@github.com:saketgahlot/sift.git
   ```
2. Open `Sift.xcodeproj` in Xcode.
3. Select an iOS simulator or a connected device and **Run** (⌘R).

> **Note:** Classification with the camera requires a real device (simulators have no camera); photo-library classification works everywhere.

## Roadmap ideas

- AR-based live scanning
- Material-specific sorting guidance (which bin, how to prep the item)
- Curbside rules by local municipality

## License

All rights reserved unless otherwise specified.
