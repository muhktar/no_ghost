
# No Ghost 👻🔒

A modern dating app inspired by Hinge and Tinder, featuring a unique premium "Lock-In" feature that symbolizes exclusivity and deeper intent.

## 🚀 Features

### Core Features
- **Swipeable Discovery**: Browse profiles with smooth card swiping
- **Lock-In System** 🔒❤️: Premium feature for expressing strong interest
- **Carousel Photos**: Rotating photo display with circular motion effects
- **Voice Messages**: Send and receive audio messages
- **Video Calls**: Premium video calling feature
- **Real-time Chat**: Instant messaging with matches
- **Smart Matching**: Location-based and preference-based matching

### Premium Features
- **Lock-In Credits**: Special premium match requests
- **Unlimited Likes**: No daily limits on likes
- **See Who Likes You**: View all your admirers
- **Video Calling**: Face-to-face conversations
- **Advanced Filters**: More detailed preference settings

## 📱 App Flow

1. **Splash Screen** → Animated logo with ghost catching animation
2. **Welcome Screen** → Sign Up / Log In options
3. **Authentication** → Phone, Email, Google, Apple Sign-In
4. **Profile Setup** → Upload photos (min 3) + prompts (min 3)
5. **Discovery** → Main swiping interface with Lock-In feature
6. **Navigation**: Home, Likes, Chat, Profile

## 🛠 Tech Stack

- **Frontend**: Flutter (Cross-platform)
- **State Management**: Riverpod + Hooks
- **Navigation**: GoRouter
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Messaging
  - Analytics
- **Payments**: In-App Purchases
- **Real-time**: Firebase Realtime Database
- **Media**: Image/Video processing
- **Animations**: Lottie + Flutter Animate

## 🎨 Design System

- **Style**: Minimalist, modern UI inspired by reference designs
- **Theme**: Light and dark mode support
- **Animations**: Smooth transitions and micro-interactions
- **Typography**: Clean, readable fonts
- **Colors**: Warm, inviting palette with accent colors

## 🔐 Security & Safety

- **AI Moderation**: Text toxicity filtering
- **Image Filtering**: NSFW content detection
- **Report System**: User reporting and blocking
- **Privacy Controls**: Granular privacy settings
- **Data Protection**: Secure data handling

## 📦 Project Structure

```
lib/
├── core/
│   ├── router/          # App navigation
│   ├── theme/           # App theming
│   └── constants/       # App constants
├── features/
│   ├── splash/          # Splash screen
│   ├── auth/            # Authentication
│   ├── discovery/       # Main swiping interface
│   ├── likes/           # Likes management
│   ├── chat/            # Messaging system
│   ├── profile/         # User profiles
│   └── subscription/    # Premium features
└── shared/
    ├── widgets/         # Reusable widgets
    ├── models/          # Data models
    ├── providers/       # State providers
    ├── services/        # API services
    └── utils/           # Utilities
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7.0+
- Dart 3.0+
- Firebase account and project setup
- iOS/Android development environment

### Installation

1. Clone the repository
```bash
git clone https://github.com/[username]/no_ghost.git
cd no_ghost
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
```bash
# Follow Firebase setup instructions for your platform
# Add google-services.json (Android) and GoogleService-Info.plist (iOS)
```

4. Run the app
```bash
flutter run
```

## 🎯 Key Screens

### Discovery Screen
- Carousel photo display with circular rotation
- Connect button (replaces "Next")
- Lock-In super like option
- Previous profile navigation (2 times max)
- Skip with name/age display

### Lock-In Feature 🔒❤️
- Premium match request system
- Heart animation → lock closing effect
- Special notification for receiver
- Profile highlighting for Lock-In matches

### Chat System
- Text messages with emoji support
- Voice message recording/playback
- GIF and meme sharing
- Video calls (premium)

## 📋 Development Roadmap

- [x] Project setup and architecture
- [ ] Authentication system
- [ ] Core UI components
- [ ] Discovery screen with swiping
- [ ] Lock-In feature implementation
- [ ] Chat system
- [ ] Premium subscription
- [ ] Firebase integration
- [ ] Push notifications
- [ ] Testing and optimization

## 🤝 Contributing

This is a private project. Please follow the established code style and patterns when making changes.

## 📄 License

This project is private and confidential.

---

**No Ghost** - Where authentic connections happen 👻💕
