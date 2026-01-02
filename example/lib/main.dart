import 'package:flutter/material.dart';
import 'package:freerasp/freerasp.dart';
import 'package:freerasp_example/app/app.dart';
import 'package:freerasp_example/config/talsec_config.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.locationWhenInUse.request();

  final config = createTalsecConfig();
  await Talsec.instance.start(config);

  runApp(const MyApp());
}
