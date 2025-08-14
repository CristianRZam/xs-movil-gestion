import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
// Verificar que se cargó correctamente
  print('BASE_URL: ${dotenv.env['BASE_URL']}');
  print('API_KEY: ${dotenv.env['API_KEY']}');
  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
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
          title: 'Simulador Yape',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
