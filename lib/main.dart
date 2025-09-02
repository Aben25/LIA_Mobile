import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'providers/theme_provider.dart';
import 'providers/supabase_provider.dart';
import 'config/supabase_config.dart';
import 'utils/easy_loading_config.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_app_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Configure EasyLoading
  EasyLoadingConfig.configure();

  runApp(const LoveInActionApp());
}

class LoveInActionApp extends StatelessWidget {
  const LoveInActionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SupabaseProvider()),
      ],
      child: Consumer<SupabaseProvider>(
        builder: (context, supabaseProvider, child) {
          // Initialize Supabase auth when the app starts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            supabaseProvider.initializeAuth();
          });

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Love in Action',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,
                theme: themeProvider.getThemeData(Brightness.light),
                darkTheme: themeProvider.getThemeData(Brightness.dark),
                home: supabaseProvider.initialized
                    ? (supabaseProvider.user != null
                        ? const MainAppScreen()
                        : const WelcomeScreen())
                    : const WelcomeScreen(),
                builder: EasyLoading.init(
                  builder: (context, child) {
                    // Configure EasyLoading based on current theme
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (themeProvider.isDarkMode) {
                        EasyLoadingConfig.configureForDarkMode();
                      } else {
                        EasyLoadingConfig.configureForLightMode();
                      }
                    });
                    return child!;
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
