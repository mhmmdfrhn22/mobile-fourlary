import 'package:flutter/material.dart';
import 'package:mobile/views/onboarding/onboarding_page.dart';
import 'package:mobile/views/auth/login_view.dart';
import 'package:mobile/views/auth/register_view.dart';
import 'package:mobile/views/main_layout.dart';
import 'app_routes.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.onboarding: (_) => const OnboardingPage(),
    AppRoutes.login: (_) => const LoginView(),
    AppRoutes.register: (_) => const RegisterView(),
    AppRoutes.home: (_) => const MainLayout(),
  };
}