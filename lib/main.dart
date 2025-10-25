import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'providers/theme_provider.dart';
// Commented out during transition to Strapi
// import 'providers/supabase_provider.dart';
// import 'providers/firebase_auth_provider.dart';
import 'providers/strapi_auth_provider.dart';
// import 'config/supabase_config.dart';
import 'utils/app_messaging.dart';
import 'router/app_router.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (commented out during transition to Strapi)
  // await SupabaseConfig.initialize();

  // Configure EasyLoading will be done in the widget
  // Initialize Firebase (commented out during transition to Strapi)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const LoveInActionApp());
}

class LoveInActionApp extends StatelessWidget {
  const LoveInActionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Commented out during transition to Strapi
        // ChangeNotifierProvider(create: (_) => SupabaseProvider()),
        // ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (_) {
          final provider = StrapiAuthProvider();
          // Initialize auth once when provider is created
          provider.initializeAuth();
          return provider;
        }),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Configure messaging for current theme
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppMessaging.configureForTheme(context);
          });

          return MaterialApp.router(
            title: 'Love in Action',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: themeProvider.getThemeData(Brightness.light),
            darkTheme: themeProvider.getThemeData(Brightness.dark),
            routerConfig: AppRouter.createRouter(),
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}
