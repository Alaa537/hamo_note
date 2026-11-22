import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final provider = AppProvider();
  await provider.init();
  runApp(HamoApp(provider: provider));
}

class HamoApp extends StatelessWidget {
  final AppProvider provider;
  const HamoApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<AppProvider>(
        builder: (context, p, _) => MaterialApp(
          title: 'Hamo Note',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: p.themeMode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
