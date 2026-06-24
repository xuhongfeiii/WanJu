import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/encryption_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDisplayMode.setHighRefreshRate();
  
  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Initialize encryption
  await EncryptionService.init();

  // Initialize Hive
  await StorageService.init();
  
  // Set preferred orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const WanjuApp());
}

class ThemeScope extends InheritedWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const ThemeScope({
    super.key,
    required this.isDark,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeScope>();
  }

  void updateTheme(bool dark) {
    if (isDark != dark) {
      toggleTheme();
    }
  }

  @override
  bool updateShouldNotify(ThemeScope oldWidget) {
    return isDark != oldWidget.isDark;
  }
}

class WanjuApp extends StatefulWidget {
  const WanjuApp({super.key});

  @override
  State<WanjuApp> createState() => _WanjuAppState();
}

class _WanjuAppState extends State<WanjuApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    final settings = StorageService.getSettings();
    _isDark = settings.darkTheme;
    _updateSystemUI();
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
    _updateSystemUI();
    final settings = StorageService.getSettings();
    settings.darkTheme = _isDark;
    StorageService.saveSettings(settings);
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: _isDark ? Brightness.light : Brightness.dark,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    ));
  }

  Widget _buildApp({required bool isDark}) {
    return ThemeScope(
      key: ValueKey(isDark),
      isDark: isDark,
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        title: '万聚',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: AppTheme.primary,
          scaffoldBackgroundColor: AppTheme.background,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppTheme.background,
            elevation: 0,
            iconTheme: IconThemeData(color: AppTheme.onSurface),
            titleTextStyle: TextStyle(
              color: AppTheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: AppTheme.background,
            surface: AppTheme.surface,
            onSurface: AppTheme.onSurface,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppTheme.primaryDark,
          scaffoldBackgroundColor: AppTheme.backgroundDark,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: AppTheme.backgroundDark,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppTheme.onSurfaceDark),
            titleTextStyle: const TextStyle(
              color: AppTheme.onSurfaceDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primaryDark,
            onPrimary: AppTheme.backgroundDark,
            surface: AppTheme.surfaceDark,
            onSurface: AppTheme.onSurfaceDark,
          ),
        ),
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _buildApp(isDark: _isDark),
    );
  }
}