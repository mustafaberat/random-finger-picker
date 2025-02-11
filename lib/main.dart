import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
