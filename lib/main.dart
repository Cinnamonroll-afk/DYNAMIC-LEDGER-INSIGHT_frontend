import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fincontrol/features/auth/bloc/auth_bloc.dart';
import 'package:fincontrol/features/auth/bloc/auth_state.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_bloc.dart';
import 'package:fincontrol/features/transaction/bloc/transaction_event.dart';
import 'package:fincontrol/features/transaction/data/repositories/transaction_repository.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/portfolio_event.dart';
import 'package:fincontrol/features/wealth/data/repositories/portfolio_repository.dart';
import 'package:fincontrol/features/wealth/bloc/asset_bloc.dart';
import 'package:fincontrol/features/wealth/bloc/asset_event.dart';
import 'package:fincontrol/features/wealth/data/repositories/asset_repository.dart';
import 'package:fincontrol/features/wealth/data/repositories/market_api_repository.dart';
import 'package:fincontrol/features/auth/data/repositories/auth_repository.dart';
import 'package:fincontrol/features/navigation/presentation/widgets/bottom_navigation_bar.dart';
import 'package:fincontrol/features/splash/presentation/pages/splash_page.dart';
import 'package:fincontrol/features/profile/presentation/widgets/app_lock_wrapper.dart';
import 'package:fincontrol/features/settings/bloc/currency_cubit.dart';
import 'package:fincontrol/core/theme/app_theme.dart';
import 'package:fincontrol/features/settings/bloc/theme_cubit.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fincontrol/l10n/app_localizations.dart';
import 'package:fincontrol/features/settings/bloc/language_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final authRepository = AuthRepository();
  final isLoggedIn = await authRepository.isLoggedIn();

  runApp(MyApp(authRepository: authRepository, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final bool isLoggedIn;

  const MyApp({super.key, required this.authRepository, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => CurrencyCubit()),
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: authRepository,
            isLoggedIn: isLoggedIn,
          ),
        ),
        // ✅ แก้: load ข้อมูลเฉพาะเมื่อ isLoggedIn = true เท่านั้น
        // ถ้าไม่ login อยู่ ให้ listener ใน BlocConsumer จัดการแทน
        BlocProvider(
          create: (context) {
            final bloc = TransactionBloc(transactionRepository: TransactionRepository());
            if (isLoggedIn) bloc.add(const LoadTransactions(''));
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) {
            final bloc = PortfolioBloc(portfolioRepository: PortfolioRepository());
            if (isLoggedIn) bloc.add(const LoadPortfolios(''));
            return bloc;
          },
        ),
        BlocProvider(
          create: (context) {
            final bloc = AssetBloc(assetRepository: AssetRepository(), marketApiRepository: MarketApiRepository());
            if (isLoggedIn) bloc.add(const LoadAssets());
            return bloc;
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LanguageCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp(
                title: 'FinControl',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('th'),
                ],
                home: AppLockWrapper(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listenWhen: (previous, current) =>
                        previous.status != current.status,
                    listener: (context, state) {
                      if (state.status == AuthStatus.initial) {
                        // Logged out — wipe all data BLoCs immediately
                        context.read<TransactionBloc>().add(const ClearTransactions());
                        context.read<PortfolioBloc>().add(const ClearPortfolios());
                        context.read<AssetBloc>().add(const ClearAssets());
                      } else if (state.status == AuthStatus.authenticated) {
                        // Just logged in / registered — reload fresh data for this user
                        context.read<TransactionBloc>().add(const LoadTransactions(''));
                        context.read<PortfolioBloc>().add(const LoadPortfolios(''));
                        context.read<AssetBloc>().add(const LoadAssets());
                      }
                    },
                    builder: (context, state) {
                      if (state.status == AuthStatus.authenticated) {
                        return const MainNavigationShell();
                      }
                      return const GetStartedView();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
