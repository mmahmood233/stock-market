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

## Complete Feature List

### Authentication & User Management
- ✅ Email/password login with validation
- ✅ User registration with initial $1,000,000 balance
- ✅ Session persistence
- ✅ Secure logout
- ✅ Profile display with user info

### Stock Market Features
- ✅ 20 stocks monitored (AAPL, GOOGL, MSFT, AMZN, TSLA, etc.)
- ✅ Real-time WebSocket updates (5+ times per second)
- ✅ Search stocks by symbol or name
- ✅ Filter results in real-time
- ✅ Pull-to-refresh functionality
- ✅ Offline mode with cached data
- ✅ Live/Offline connection indicator

### Stock Details & Analysis
- ✅ Detailed stock information (price, volume, high/low)
- ✅ Interactive fl_chart line charts
- ✅ 5 time period options (1D, 1W, 1M, 1Y, ALL)
- ✅ Touch tooltips with price and date
- ✅ Auto-scaling chart axes
- ✅ Color-coded performance indicators

### Trading System
- ✅ Buy stocks with balance validation
- ✅ Sell stocks with holdings validation
- ✅ Real-time cost/revenue calculation
- ✅ Quantity input with validation
- ✅ Insufficient balance prevention
- ✅ Insufficient shares prevention
- ✅ Transaction confirmation dialogs

### Portfolio Management
- ✅ Portfolio summary with total metrics
- ✅ Total value, investment, and P/L display
- ✅ Individual stock holdings
- ✅ Quantity, average price, current value per stock
- ✅ Per-stock profit/loss tracking
- ✅ Color-coded profit/loss indicators
- ✅ Holdings count display

### Transaction History
- ✅ Complete transaction audit trail
- ✅ Buy/sell transaction records
- ✅ Transaction details (quantity, price, date)
- ✅ Chronological sorting (newest first)
- ✅ Color-coded transaction types

### User Experience
- ✅ Material 3 design system
- ✅ Light and dark theme support
- ✅ Smooth animations and transitions
- ✅ Loading states with spinners
- ✅ Empty states with call-to-actions
- ✅ Error states with retry buttons
- ✅ Success/error notifications
- ✅ Responsive layouts
- ✅ Bottom navigation
- ✅ Intuitive user flows

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

### Quick Start Guide

1. **Sign Up**: Create an account with email, password, and name
2. **Explore Market**: Browse 20 stocks with real-time prices
3. **View Details**: Tap any stock to see charts and details
4. **Buy Stocks**: Use your $1,000,000 to purchase shares
5. **Track Portfolio**: Monitor your holdings and profit/loss
6. **Sell Stocks**: Sell shares when ready
7. **View History**: Check all your transactions

## Project Phases

- [x] Phase 1: Project setup and architecture ✅
- [x] Phase 2: Core models and data layer ✅
- [x] Phase 3: State management (BLoC) ✅
- [x] Phase 4: Authentication ✅
- [x] Phase 5: Stock list with real-time updates ✅
- [x] Phase 6: Wallet functionality ✅
- [x] Phase 7: Stock details and charts ✅
- [x] Phase 8: Trading functionality ✅
- [x] Phase 9: Polish and testing ✅

**🎉 PROJECT COMPLETE - All phases implemented!**

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
