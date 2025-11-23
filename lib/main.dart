import 'package:flutter/material.dart';
import 'user_preferences.dart'; // Import the UserPreferences file
import 'core/routes/app_routes.dart'; // Import your routes
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if the user is already logged in
  bool loggedIn = await UserPreferences.isLoggedIn();
  
  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fourlary App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: isLoggedIn ? AppRoutes.home : AppRoutes.onboarding, // Navigate based on login state
      routes: AppPages.routes,
    );
  }
}
