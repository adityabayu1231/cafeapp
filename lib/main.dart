import 'package:flutter/material.dart';
import 'features/auth/injection_container.dart' as auth_di;
import 'features/auth/presentation/pages/login_page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await auth_di.initAuthModule(
    onUnauthenticated: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Cafe App',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const LoginPage(),
    );
  }
}