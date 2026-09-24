import 'package:app_movil_sistema/core/authorization/access_control.dart';
import 'package:app_movil_sistema/core/session/session_coordinator.dart';
import 'core/storage/token_storage.dart';
import 'package:app_movil_sistema/core/service_locator.dart';
import 'package:app_movil_sistema/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/notification/presentation/bloc/notification_cubit.dart';
import 'routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  setupLocator();
  getIt<AccessControl>().updateToken(await getIt<TokenStorage>().getToken());
  getIt<SessionCoordinator>();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider.value(value: getIt<NotificationCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          navigatorKey: getIt<SessionCoordinator>().navigatorKey,
          title: 'Sistema de Gestión',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: const Locale('es'),
          supportedLocales: const [Locale('es'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routes: AppRoutes.routes,
          home: const SplashScreen(),
        );
      },
    );
  }
}
