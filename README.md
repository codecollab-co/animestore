![](https://github.com/sc4v3ng3r/animeapp_course/blob/development/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png?raw=true)
# Anime Store

Anime Store is a modern, beautiful, lightweight and open source mobile app for streaming anime without ads. Built with Flutter and featuring a clean BLoC architecture, it provides multilingual support (English and Brazilian Portuguese) with features including daily releases, top anime rankings, recent episodes, and personal watchlists.

<p float="left">
  <img src="https://s5.gifyu.com/images/app_startupf7a34bdb2ef8352f.gif" width="250" />
  <img src="https://s5.gifyu.com/images/home_to_details00ff993998186b6a.gif" width="250" />
  <img src="https://s5.gifyu.com/images/playe14beaa32c2b9207.gif" width="250" />
</p>

## 🎯 Architecture

Anime Store uses a **dual-API architecture** for optimal data delivery:

- **[Jikan API](https://jikan.moe/)** (MyAnimeList) - Provides comprehensive anime metadata, search, rankings, and genre information
- **[Consumet API](https://github.com/consumet/api.consumet.org)** - Handles video streaming with multi-provider support

The app follows clean architecture principles with:
- **BLoC State Management** - Reactive, testable state management using flutter_bloc
- **Repository Pattern** - Clean separation between data sources and business logic
- **Custom API-agnostic Models** - Unified data models independent of API structure
- **Converter Pattern** - Transforms external API responses to internal models

## ⚠️ Legal Disclaimer

**Anime Store has no copyrights of the content and is not the uploader or keeper of any content. This app is for educational purposes and demonstrates Flutter development skills. Users are responsible for ensuring their usage complies with local copyright laws.**
 

## 🚀 Features

- **Browse Anime** - Explore top anime, seasonal releases, and trending titles
- **Advanced Search** - Find anime by title with pagination support
- **Genre Discovery** - Browse anime by your favorite genres
- **Personal Watchlist** - Save and manage your anime collection
- **Episode Tracking** - Track watched episodes and continue where you left off
- **Video Streaming** - Watch anime episodes with integrated video player
- **Multilingual** - Support for English and Brazilian Portuguese
- **Material Design** - Beautiful, responsive UI following Material Design guidelines

## 📋 Requirements

- Flutter SDK 3.0+
- Dart 2.17+
- Android Studio / Xcode for mobile development

## 🛠️ Installation & Setup

### Clone the Repository

```bash
git clone https://github.com/codecollab-co/animestore.git
cd animestore
```

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
# Development mode
flutter run

# Profile mode (better performance)
flutter run --profile

# Release mode
flutter run --release
```

### Build APK (Android)

```bash
flutter build apk --release
```

**Note:** Release builds require a signing key. For development, use debug builds or profile mode.

### Build for iOS

```bash
flutter build ios --release
```

**Note:** iOS builds require a Mac with Xcode installed.

## 🏗️ Project Structure

```
lib/
├── data/
│   ├── database/           # SQLite database layer
│   └── repositories/       # Data repositories (Jikan, Consumet, User)
├── logic/
│   ├── blocs/             # BLoC state management
│   │   ├── application/   # App-wide state
│   │   ├── anime_details/ # Anime details screen
│   │   ├── search/        # Search functionality
│   │   ├── video_player/  # Video playback
│   │   └── ...
│   └── Constants.dart     # App-wide constants
├── models/                # Data models
│   ├── anime_model.dart
│   ├── episode_model.dart
│   └── converters/        # API response converters
├── ui/
│   ├── component/         # Reusable UI components
│   ├── pages/            # App screens
│   └── theme/            # Theme configuration
└── main.dart             # App entry point
```

## 📝 Recent Major Updates

### **v2.0.0 - Complete API Migration & BLoC Refactor** 🚀

This major release represents a complete architectural overhaul of the app:

#### **Architecture Migration**
- ✅ **MobX → BLoC** - Complete migration to flutter_bloc for state management
- ✅ **AniTube → Jikan + Consumet** - Migrated from deprecated AniTube API to dual-API architecture
- ✅ **Custom API-agnostic Models** - Built unified models independent of API structure
- ✅ **Repository Layer Rewrite** - Implemented clean repository pattern

#### **Core Infrastructure**
- **AnimeRepository** - Unified interface for anime operations
- **JikanRepository** - MyAnimeList metadata integration
- **ConsumetRepository** - Multi-provider video streaming support
- **GenreRepository** - Genre management and filtering
- **UserRepository** - User data and preferences with SQLite backend

#### **State Management (BLoC)**
- **ApplicationBloc** - Global app state, watchlist, and episode tracking
- **AnimeDetailsBloc** - Anime details and episodes
- **SearchBloc** - Jikan-powered search with pagination
- **VideoPlayerBloc** - Video playback with episode navigation
- **GenreBloc** - Genre-filtered anime browsing
- **HomeBloc** - Home page feed management

#### **Data Models**
- **AnimeModel** - Unified anime data structure
- **EpisodeModel** - Episode data with streaming info
- **GenreModel**, **SearchResultModel**, **HomePageModel**
- **JikanConverter**, **ConsumetConverter** - API transformation layer

#### **Zero Compilation Errors** 🎯
- Started with 175 errors → Final: **0 errors**
- Production-ready codebase with complete null safety
- All deprecated APIs updated to current Flutter standards

#### **Code Quality Improvements**
- Removed inconsistent 'new' keyword usage
- Standardized variable declarations for type safety
- Fixed constant naming conventions
- Organized imports following Dart conventions
- Updated deprecated Flutter APIs (bodyText2 → bodyMedium, etc.)
- Removed dead code and unused imports

### **Files Changed**
- **Modified:** 31+ files across the codebase
- **Deleted:** 10 MobX store files
- **Added:** 50+ new files (models, repositories, BLoCs)

## 🐛 Known Issues & Roadmap

See our [GitHub Issues](https://github.com/codecollab-co/animestore/issues) for the complete list of improvements and planned features.

### High Priority
- Deploy Consumet API to production
- Implement comprehensive error handling
- Add proper logging framework
- Implement image caching strategy

### Medium Priority
- Increase test coverage (currently ~3%)
- Add watch progress tracking with percentage
- Improve loading states with skeleton loaders
- Add retry mechanisms for failed operations

### Low Priority
- Dark/light theme toggle
- Personalized recommendations
- Push notifications for new episodes
- Offline mode with caching

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available for educational purposes. Please ensure your usage complies with local copyright laws regarding anime content.

## 🙏 Acknowledgments

- [Jikan API](https://jikan.moe/) - MyAnimeList unofficial API
- [Consumet API](https://github.com/consumet/api.consumet.org) - Multi-provider anime streaming API
- Original concept inspired by [sc4v3ng3r's anime app](https://github.com/sc4v3ng3r/animeapp_course)

---

**Note:** This app is for educational purposes. All anime content is sourced from third-party APIs. We do not host or own any content.
