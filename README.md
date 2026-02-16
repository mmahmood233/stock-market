# Stock Market Simulation App

A real-time stock market simulation app built with Flutter following clean architecture principles.

## Features

- **Authentication**: Login/Signup with user account management
- **Real-time Stock Data**: Monitor 20 stocks with updates 5+ times per second
- **Wallet Management**: Track portfolio with $1,000,000 starting balance
- **Stock Trading**: Buy, sell, and hold stocks with real-time pricing
- **Historical Charts**: View stock performance over time (day, week, month, year)
- **Offline Support**: Cached data and graceful error handling

## Architecture

This project follows **Clean Architecture** principles with **BLoC** pattern for state management:

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── theme/          # Theme and styling
│   ├── utils/          # Utility functions
│   └── errors/         # Error handling
├── data/
│   ├── models/         # Data models (DTOs)
│   ├── repositories/   # Repository implementations
│   └── datasources/    # API and local data sources
├── domain/
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business logic
└── presentation/
    ├── bloc/           # BLoC state management
    ├── pages/          # UI screens
    └── widgets/        # Reusable UI components
```

## Clean Code Principles Applied

1. **UI as Dumb Layer**: UI only renders state and forwards actions
2. **Unidirectional Data Flow**: User Action → BLoC → State → UI
3. **State Management**: Explicit handling of loading, success, error, empty states
4. **Separated Models**: API → Domain → UI model layers
5. **Offline-First**: Cached data with retry mechanisms
6. **Lifecycle Aware**: Proper handling of app pause/resume
7. **Performance Optimized**: Non-blocking operations, efficient list rendering

## Getting Started

### Prerequisites

- Flutter SDK (3.10.8 or higher)
- Dart SDK
- iOS Simulator / Android Emulator / Physical Device

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Phases

- [x] Phase 1: Project setup and architecture
- [ ] Phase 2: Core models and data layer
- [ ] Phase 3: State management (BLoC)
- [ ] Phase 4: Authentication
- [ ] Phase 5: Stock list with real-time updates
- [ ] Phase 6: Wallet functionality
- [ ] Phase 7: Stock details and charts
- [ ] Phase 8: Trading functionality
- [ ] Phase 9: Polish and testing

## Dependencies

- **flutter_bloc**: State management
- **equatable**: Value equality
- **http**: REST API calls
- **web_socket_channel**: Real-time data
- **sqflite**: Local database
- **shared_preferences**: Key-value storage
- **fl_chart**: Stock charts
- **google_fonts**: Typography
- **intl**: Formatting and localization
