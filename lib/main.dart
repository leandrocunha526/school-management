import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Educadores/EducadoresList.dart';
import 'Login/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFF002D72), // cor igual à app bar
    statusBarIconBrightness: Brightness.light, // ícones brancos
  ));

  await Supabase.initialize(
    url: 'YOURURL',
    anonKey: 'YOURKEY',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final client = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Escolar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF002D72),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: client.auth.currentUser != null
          ? const EducadoresList()
          : const LoginScreen(),
    );
  }
}
