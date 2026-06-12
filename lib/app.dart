import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class ScriptLabApp extends StatelessWidget {
  const ScriptLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeController.to.mode.value,
      initialRoute: AppRoutes.dashboard,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 180),
    );
  }
}
