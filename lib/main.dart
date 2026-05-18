import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/portfolio/portfolio_bloc.dart';
import 'presentation/bloc/stock/stock_bloc.dart';
import 'presentation/bloc/stock_history/stock_history_bloc.dart';
import 'presentation/pages/splash_page.dart';

/// App entry point.
///
/// This is called by Flutter first. It prepares local storage and all shared
/// app services through [InjectionContainer], then starts the root widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectionContainer.init();
  runApp(const StockMarketApp());
}

/// Root widget used by the whole app.
///
/// It provides every BLoC used by the pages:
/// [AuthBloc] for login, [StockBloc] for live prices, [PortfolioBloc] for the
/// Wallet, and [StockHistoryBloc] for charts.
class StockMarketApp extends StatelessWidget {
  const StockMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => InjectionContainer.authBloc),
        BlocProvider<StockBloc>(create: (_) => InjectionContainer.stockBloc),
        BlocProvider<PortfolioBloc>(
          create: (_) => InjectionContainer.portfolioBloc,
        ),
        BlocProvider<StockHistoryBloc>(
          create: (_) => InjectionContainer.stockHistoryBloc,
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashPage(),
      ),
    );
  }
}
