# 🖐️ Handsconnect Webapp

An AI-powered, real-time hand tracking web application built with **Flutter** and **MediaPipe**. This project features a stunning dynamic visualizer that generates a 21-point geometric hand wireframe alongside interactive "string-art" cross-hand connections, all rendered in a beautiful glowing neon rainbow spectrum.

## ✨ Features

* **Real-time Computer Vision**: Powered by Google's MediaPipe Hands, tracking 21 3D landmarks per hand in real-time.
* **Full Rainbow Geometry**: Draws a precise skeletal mesh over the fingers and palms that dynamically cycles through the full HSV rainbow spectrum.
* **Interactive String Art**: Automatically renders dense, horizontal connecting strings between your left and right hands when both are detected.
* **Double Bloom Glow**: Implements a highly optimized, two-pass rendering system (Bloom layer + Core layer) using Flutter's `MaskFilter.blur` to create an intense neon aesthetic.
* **60 FPS Optimized**: Uses `RepaintBoundary` and a 16ms polling rate (via JS Interop) to ensure the heavy canvas painting runs buttery smooth without lagging the rest of the UI.
* **Dark UI Theme**: Wrapped in a modern, minimalist deep-dark UI (`#0F0F13`) to make the neon lines pop.

## 🚀 Live Demo

**[Click here to view the live app on GitHub Pages!](https://muneeza-apps.github.io/Handsconnect-webapp/)**

*(Note: Please allow camera permissions for the app to function correctly. No video data is ever saved or sent to any server; all AI processing happens locally in your browser!)*

## 🛠️ Technology Stack

* **Frontend**: [Flutter Web](https://flutter.dev/web) (Dart)
* **AI / ML**: [MediaPipe JS Interop](https://google.github.io/mediapipe/solutions/hands.html)
* **Graphics**: Flutter CustomPainter / Canvas API
* **Deployment**: GitHub Pages

## 💻 Running Locally

To run this project on your local machine:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/muneeza-apps/Handsconnect-webapp.git
   cd Handsconnect-webapp
   ```

2. **Install Dependencies:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Run on Chrome:**
   ```bash
   flutter run -d chrome
   ```

## 📦 Building for Production (GitHub Pages)

To manually build and update the `docs/` folder for GitHub Pages deployment, run the following command:

```bash
flutter build web --release --base-href "/Handsconnect-webapp/"
```
After building, simply copy the contents of `build/web/` into the `docs/` folder, commit, and push!

---
*Developed with ❤️ by [Muneeza-apps](https://github.com/muneeza-apps)*
