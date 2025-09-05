import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'providers/theme_provider.dart';
import 'providers/supabase_provider.dart';
import 'providers/firebase_auth_provider.dart';
import 'providers/strapi_auth_provider.dart';
import 'config/supabase_config.dart';
import 'utils/easy_loading_config.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/auth/verification_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Configure EasyLoading
  EasyLoadingConfig.configure();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) => StrapiAuthProvider()),
      ],
      child: Consumer3<SupabaseProvider, FirebaseAuthProvider, StrapiAuthProvider>(
        builder: (context, supabaseProvider, firebaseAuthProvider, strapiAuthProvider, child) {
          // Initialize Supabase auth when the app starts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            supabaseProvider.initializeAuth();
            // Initialize Firebase auth when the app starts (for gradual migration)
            final firebaseAuthProvider =
                Provider.of<FirebaseAuthProvider>(context, listen: false);
            firebaseAuthProvider.initializeAuth();
            // Initialize Strapi auth (primary auth)
            final strapiProvider =
                Provider.of<StrapiAuthProvider>(context, listen: false);
            strapiProvider.initializeAuth();
          });

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'Love in Action',
                debugShowCheckedModeBanner: false,
                themeMode: themeProvider.themeMode,
                theme: themeProvider.getThemeData(Brightness.light),
                darkTheme: themeProvider.getThemeData(Brightness.dark),
                home: () {
                  // Use Strapi for authentication gating
                  if (!strapiAuthProvider.initialized) {
                    return const WelcomeScreen();
                  }
                  if (!strapiAuthProvider.isAuthenticated) {
                    return const WelcomeScreen();
                  }
                  return const MainAppScreen();
                }(),
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
