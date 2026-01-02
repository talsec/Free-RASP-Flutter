import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/app/app.dart';
import 'package:freerasp_example/config/talsec_config.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.locationWhenInUse.request();

  // Initialize Talsec configuration
  try {
    final config = createTalsecConfig();
    await Talsec.instance.start(config);
  } catch (e) {
    // Log error but allow app to continue
    // In production, you might want to use a logging service or show an error dialog
    debugPrint('Error initializing Talsec: $e');
    // Re-throw if you want the app to fail fast on initialization errors
    // rethrow;
  }

  runApp(const MyApp());
}
