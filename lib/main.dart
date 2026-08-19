import 'package:flutter/material.dart';
import 'features/auth/injection_container.dart' as auth_di;
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await auth_di.initAuthModule();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cafe App',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const LoginPage(),
    );
  }
}