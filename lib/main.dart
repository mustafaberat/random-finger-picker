import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/game_screen.dart';
import 'services/localization_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalizationService.instance.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  runApp(const RandomFingerPickerApp());
}

class RandomFingerPickerApp extends StatelessWidget {
  const RandomFingerPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Finger Picker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('tr'), // Turkish
        const Locale('zh'), // Chinese
        const Locale('es'), // Spanish
        const Locale('de'), // German
        const Locale('fr'), // French
        const Locale('ru'), // Russian
        const Locale('ja'), // Japanese
        const Locale('pt'), // Portuguese
        const Locale('it'), // Italian
        const Locale('ko'), // Korean
        const Locale('ar'), // Arabic
        const Locale('hi'), // Hindi
        const Locale('id'), // Indonesian
        const Locale('pl'), // Polish
        const Locale('nl'), // Dutch
        const Locale('sv'), // Swedish
        const Locale('th'), // Thai
        const Locale('ms'), // Malay
      ],
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
