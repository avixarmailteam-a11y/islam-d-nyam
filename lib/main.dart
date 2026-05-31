import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sadece dikey mod
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Durum çubuğu rengi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Bildirim servisini başlat
  await NotificationService.initialize();

  // Arka plan servisini başlat
  await BackgroundService.initialize();

  runApp(const IslamDunyamApp());
}

class IslamDunyamApp extends StatelessWidget {
  const IslamDunyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'İslam Dünyam',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A6B4B),
          primary: const Color(0xFF1A6B4B),
          secondary: const Color(0xFFD4AF37),
          tertiary: const Color(0xFF8B5E3C),
          surface: const Color(0xFFFAF9F6),
          background: const Color(0xFFF5F5F0),
          error: const Color(0xFFB00020),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F0),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFF1A6B4B),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF1A6B4B),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: const Color(0xFF1A6B4B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          displayMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          bodySmall: TextStyle(fontFamily: 'Poppins'),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
