import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/portfolio_local_datasource.dart';
import '../../data/datasources/stock_local_datasource.dart';
import '../../data/datasources/stock_remote_datasource.dart';
import '../../data/datasources/user_local_datasource.dart';
import '../../data/repositories/portfolio_repository_impl.dart';
import '../../data/repositories/stock_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/portfolio/portfolio_bloc.dart';
import '../../presentation/bloc/stock/stock_bloc.dart';
import '../../presentation/bloc/stock_history/stock_history_bloc.dart';

class InjectionContainer {
  static SharedPreferences? _sharedPreferences;
  static Uuid? _uuid;

  static StockRemoteDataSource? _stockRemoteDataSource;
  static StockLocalDataSource? _stockLocalDataSource;
  static UserLocalDataSource? _userLocalDataSource;
  static PortfolioLocalDataSource? _portfolioLocalDataSource;

  static StockRepository? _stockRepository;
  static UserRepository? _userRepository;
  static PortfolioRepository? _portfolioRepository;

  static AuthBloc? _authBloc;
  static StockBloc? _stockBloc;
  static PortfolioBloc? _portfolioBloc;
  static StockHistoryBloc? _stockHistoryBloc;

  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _uuid = const Uuid();

    _stockRemoteDataSource = StockRemoteDataSourceImpl();
    _stockLocalDataSource = StockLocalDataSourceImpl(
      sharedPreferences: _sharedPreferences!,
    );
    _userLocalDataSource = UserLocalDataSourceImpl(
      sharedPreferences: _sharedPreferences!,
      uuid: _uuid!,
    );
    _portfolioLocalDataSource = PortfolioLocalDataSourceImpl(
      sharedPreferences: _sharedPreferences!,
      uuid: _uuid!,
    );

    _stockRepository = StockRepositoryImpl(
      remoteDataSource: _stockRemoteDataSource!,
      localDataSource: _stockLocalDataSource!,
    );
    _userRepository = UserRepositoryImpl(
      localDataSource: _userLocalDataSource!,
    );
    _portfolioRepository = PortfolioRepositoryImpl(
      localDataSource: _portfolioLocalDataSource!,
    );

    _authBloc = AuthBloc(userRepository: _userRepository!);
    _stockBloc = StockBloc(stockRepository: _stockRepository!);
    _portfolioBloc = PortfolioBloc(
      portfolioRepository: _portfolioRepository!,
      authBloc: _authBloc!,
    );
    _stockHistoryBloc = StockHistoryBloc(stockRepository: _stockRepository!);
  }

  static AuthBloc get authBloc => _authBloc!;
  static StockBloc get stockBloc => _stockBloc!;
  static PortfolioBloc get portfolioBloc => _portfolioBloc!;
  static StockHistoryBloc get stockHistoryBloc => _stockHistoryBloc!;

  static void dispose() {
    _authBloc?.close();
    _stockBloc?.close();
    _portfolioBloc?.close();
    _stockHistoryBloc?.close();
    if (_stockRemoteDataSource is StockRemoteDataSourceImpl) {
      (_stockRemoteDataSource as StockRemoteDataSourceImpl).dispose();
    }
  }
}
