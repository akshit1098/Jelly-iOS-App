# Jelly-iOS-App
A 3-tab Swift iOS app featuring a TikTok-style video feed, a dual-camera interface that records synced front/back videos, and a local camera roll for playback. Built to showcase AVFoundation, media handling, and intuitive UI/UX design.


---

## 🧭 Overview

This app has **three tabs**:

1. **Feed:** A vertical TikTok-style UI showcasing videos scraped from Jelly's public website.
2. **Camera:** Record dual-camera (front & back) synchronized videos in a split-screen view.
3. **Camera Roll:** Displays recorded videos in a scrollable grid view, with inline and full-screen playback.

---

## 🧠 Tech Highlights

- `AVFoundation` – Dual-camera capture with `AVCaptureMultiCamSession`
- `SwiftUI` + `UIKit` – Combined for UI rendering and camera control
- `WKWebView` – JavaScript-powered web scraping
- `Firebase Storage` – Seamless video upload & retrieval
- `MVVM Architecture` – Clean separation of logic & presentation

---

## 🗂 File Structure

Jelly-iOS-App/
├── Jelly-iOS-App/ ← Xcode project folder
│ ├── Models/
│ │ └── Video.swift
│ ├── Services/
│ │ ├── FirebaseStorageService.swift
│ │ └── VideoService.swift
│ ├── ViewModels/
│ │ ├── FeedViewModel.swift
│ │ ├── DualCameraViewModel.swift
│ │ └── CameraRollViewModel.swift
│ ├── Views/
│ │ ├── ContentView.swift
│ │ ├── JellyFeedView.swift
│ │ ├── ScrapingWebView.swift
│ │ ├── PreviewContainer.swift
│ │ ├── VideoPlayerView.swift
│ │ ├── VideoRowView.swift
│ │ ├── MultiCamPreview.swift
│ │ ├── DualCameraView.swift
│ │ ├── CameraPreview.swift
│ │ └── CameraRollView.swift
│ ├── Assets.xcassets/
│ └── GoogleService-Info.plist
└── Screenshots/
├── filestructure.png
├── feed_screen.png
├── camera_screen.png
└── roll_screen.png

---

## 🧱 MVVM Architecture

- **Models:** Represent data structures (`Video.swift`)
- **ViewModels:** Handle business logic & state (`DualCameraViewModel`, `FeedViewModel`, `CameraRollViewModel`)
- **Views:** SwiftUI + UIViewRepresentable UIs; minimal logic
- **Services:** APIs & integrations (`FirebaseStorageService.swift`)

---

## 📸 Tab 1 – Feed

> Jelly's video feed UI mimics TikTok with swipeable vertical cards.

🧩 **UI Elements:**

- Navigation bar with **“Jelly Feed”** title
- WebView scraper extracts video links from `<link rel="prefetch">`
- Fullscreen `VideoPlayer` per card with:
  - Mute/Unmute button
  - Play/Pause
  - Like, Share, Profile icons on the right
  - Custom progress bar with seek support
  - Left/Right swipe for manual navigation
- Autoplay & auto-advance when playback ends

🖼 **Screenshot:**

![Feed Screen](Screenshots/feed_screen.png)

---

## 🎬 Tab 2 – Dual Camera

> Simultaneously captures and records from front & back cameras.

🧩 **UI Elements:**

- **MultiCamPreview**:
  - Top: back camera preview
  - Bottom: front camera preview
- **Recording Controls**:
  - Central message: “Press white button to start recording” → changes to red when recording
  - Circular record button (white for idle, red for active)
- **Post-record Spinner**:
  - Fullscreen spinner with “Saving…” message
  - Waits **5s** to allow Firebase to sync
  - Auto-switches to Tab 3 after delay

🖼 **Screenshot:**

![Camera Screen](Screenshots/camera_screen.png)

---

## 📁 Tab 3 – Camera Roll

> Displays all recorded videos in a scrollable grid fetched from Firebase.

🧩 **UI Elements:**

- Title: **Camera Roll**
- `LazyVGrid` for 2-column layout
- Each grid cell includes:
  - Thumbnail + inline playback with scrubber
  - Tap to expand full-screen
- Automatically pulls all `.mov` files from Firebase Storage

🖼 **Screenshot:**

![Roll Screen](Screenshots/roll_screen.png)

---

## 💭 Thought Process & Tradeoffs

### ✅ Feed Scraping

- **Decision:** Use JavaScript to extract videos from the `<link rel="prefetch">` tags in Jelly’s public site
- **Why:** No public API; this avoids brittle HTML parsing or authentication

### ✅ Dual-Cam AVFoundation

- **Approach:** `AVCaptureMultiCamSession` with `AVAssetWriter` to merge front/back tracks vertically
- **Limitation:** iPhone XS or newer only supports multi-cam

### ✅ Firebase Integration

- **Reason:** Simple setup for video storage without custom backend
- **Tradeoff:** Exposed Google API key – handled by later restricting domains

### ✅ UI/UX

- Clearly indicated states (e.g., prompt messages, red/white buttons)
- Custom progress indicators for better feedback
- Spinner overlay helps cover async wait before Tab 3 transition

---

## 🚀 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/akshit1098/Jelly-iOS-App.git
cd Jelly-iOS-App/Jelly-iOS-App
2. Setup Firebase
Download your GoogleService-Info.plist from Firebase

Drag it into the Xcode project under Jelly-iOS-App

⚠️ If using version control, do NOT commit GoogleService-Info.plist to public repos.

3. Build & Run
Use a real iPhone device (dual-cam only works on hardware)

Grant Camera + Microphone permissions when prompted

🌱 Future Improvements
🔐 Add Firebase Authentication to track users

💬 Add likes/comments on feed videos

🎨 Add AR filters and effects to the camera

☁️ Enable offline caching and background retry logic

✅ Increase test coverage (unit + UI tests)

📸 Screenshots
Feed (Tab 1)	Camera (Tab 2)	Camera Roll (Tab 3)

🧪 Final Notes
This project demonstrates a full-stack iOS prototype involving:

Low-level AVFoundation camera access

SwiftUI rendering and navigation

Async task handling with Combine

End-to-end media lifecycle: Capture → Encode → Upload → Display


