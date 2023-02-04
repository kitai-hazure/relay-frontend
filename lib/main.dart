import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:relay/screens/onboarding.dart';
import 'package:relay/screens/sign_in_screen.dart';
import 'package:relay/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/dependency_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies();
  // print('initScreen ${initScreen}');
  runApp(
    MaterialApp(
      home: ProviderScope(
        child: SplashScreen(),
      ),
    ),
  );
}


