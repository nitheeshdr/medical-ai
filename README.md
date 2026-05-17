<div align="center">
  <img src="https://img.icons8.com/color/144/000000/doctors-folder.png" alt="MediNova Logo" width="100"/>
  <h1>MediNova Health AI</h1>
  <p>An advanced AI Health Analytics Platform bridging the gap between personal wellness devices and intelligent medical insights.</p>
</div>

---

## 🌟 Overview

**MediNova** is a production-ready healthcare application featuring a cross-platform mobile client and a powerful administrative backend. By deeply integrating wearable metrics with multimodal large language models (LLMs), MediNova delivers highly contextualized health insights, analyzes complex medical documents, and provides secure, on-demand AI consultations.

## ✨ Key Features

- 🧠 **Context-Aware AI Chat:** An intelligent medical assistant powered by **Llama 3.2 Vision (11B)**. It securely ingests the user's latest wearable vitals and recent medical reports to provide deeply personalized answers.
- ⌚️ **Universal Wearable Sync:** Automatic, background integration with **Google Health Connect**, **Apple HealthKit**, **Samsung Health**, **Garmin**, and **Oura** via the native `health` package APIs.
- 📄 **Vision-Powered Document Analysis:** Snap a photo of a handwritten prescription or upload typed lab reports. The multimodal vision pipeline reads, extracts, and summarizes the data seamlessly.
- 🔒 **Enterprise-Grade Security:**
  - Strict native **Biometric Unlock** (FaceID/Fingerprint) protecting active sessions.
  - Secure **Firebase Authentication** pipelines utilized for account recovery and password resets.
- 📊 **Robust Admin Dashboard:** A comprehensive Next.js web portal allowing administrators to oversee active users, review uploaded reports, and monitor token usage/AI performance.

---

## 🏗️ Architecture Stack

### Mobile Application
- **Framework:** Flutter & Dart
- **State Management:** Riverpod (`AutoDisposeFamilyNotifier` for modular chat sessions)
- **Networking:** Dio with custom interceptors
- **Native APIs:** `local_auth` (Biometrics), `health` (Wearables)

### Backend & Admin Portal
- **Framework:** Next.js (App Router), React, TypeScript
- **Database:** MongoDB / Mongoose (Session & Chat History persistence)
- **Identity:** Firebase Auth, Custom JWTs
- **AI Provider:** NVIDIA NIM (Llama 3.2 Vision Instruct)

---

## 🚀 Getting Started

### Prerequisites
- Node.js 18+
- Flutter SDK 3.19+
- MongoDB instance (local or Atlas)
- Firebase Project configured

### 1. Setup Backend & Admin
```bash
cd backend
npm install

# Copy env template and fill in your keys (MONGO_URI, NVIDIA_API_KEY)
cp .env.example .env.local

# Run the backend locally
npm run dev
```

### 2. Setup Mobile App
```bash
cd mobile
flutter pub get

# Ensure proper minSdk properties for health plugins
# (Android minSdk is 26)
flutter run
```

---

## 📱 Mobile Preview & Build

To generate a standalone APK for Android deployment:
```bash
cd mobile
flutter build apk --release
```
> The generated APK will be available in `build/app/outputs/flutter-apk/app-release.apk`

---

## 🛡️ Privacy & Compliance
MediNova prioritizes user privacy. All wearable tracking data remains tightly scoped within the user's secure context. Active chat sessions are protected by biometric constraints, and authentication fallbacks employ trusted Firebase standards.

<div align="center">
  <i>Built to revolutionize personal healthcare tracking.</i>
</div>
