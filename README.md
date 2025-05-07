# 🎵 EchoPlay

**EchoPlay** is a Flutter application that allows users to download audio from YouTube links and play them directly within the app. It supports background audio playback, sharing intent for media, persistent downloads using Hive, and offline media management.

---

## 🚀 Features

- 📥 Download audio from YouTube using `youtube_explode_dart`
- 🎧 Play audio with `just_audio` + `just_audio_background`
- 💾 Persistent storage using `hive`
- 🔗 Receive media via sharing intents
- 🎨 Thumbnail-rich UI with blurred background effects
- 📂 Download progress tracking and file management
- ✅ Designed with `GetX` for state management

---


## 🧰 Tech Stack

- **Flutter**
- **Dart**
- [youtube_explode_dart](https://pub.dev/packages/youtube_explode_dart)
- [just_audio](https://pub.dev/packages/just_audio)
- [get](https://pub.dev/packages/get)
- [hive](https://pub.dev/packages/hive)
- [receive_sharing_intent](https://pub.dev/packages/receive_sharing_intent)

---

## 🛠️ Getting Started

### 1. Clone the repository

    git clone https://github.com/your-username/echoplay.git
    cd echoplay
### 2. Install dependencies


`flutter pub get`

### 3. Run the app


`flutter run`

> Ensure you test on a physical device or emulator with access to file storage and audio output.



## ⚙️ Setup Notes

-   This app uses  `just_audio_background`  which requires additional configuration for Android (e.g., permissions and foreground service).

-   Sharing intents (`receive_sharing_intent`) only work properly on Android. Ensure the right intent filters are added in  `AndroidManifest.xml`.


----------

## 🧪 Development Tips

-   📁 All downloaded files are saved in the app's documents directory.

-   🧠 Downloads are saved using Hive with the  `FileData`  model.

-   🛑 App automatically prevents duplicate download entries using  `video.id`.


----------

## 📜 License

MIT License. See  `LICENSE`  for more information.

----------

## 🙌 Acknowledgements

-   Thanks to  [YoutubeExplode Dart](https://github.com/Hexer10/youtube_explode_dart)



----------
