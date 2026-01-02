// ignore_for_file: public_member_api_docs
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freerasp_example/screens/security_screen.dart';
import 'package:freerasp_example/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          final lightScheme =
              AppTheme.getScheme(lightDynamic, Brightness.light);
          final darkScheme = AppTheme.getScheme(darkDynamic, Brightness.dark);

          return MaterialApp(
            restorationScopeId: 'root',
            title: 'My Secure App',
            theme: AppTheme.create(lightScheme),
            darkTheme: AppTheme.create(darkScheme),
            home: const SecurityScreen(),
          );
        },
      ),
    );
  }
}
