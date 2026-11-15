import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fit_log/views/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Seus dados reais de conexão com o Firebase Web
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBszvuOj0nA0ob8e3JPEnNLiBf6KHSL3_I",
      authDomain: "fitlog-academia.firebaseapp.com",
      projectId: "fitlog-academia",
      storageBucket: "fitlog-academia.firebasestorage.app",
      messagingSenderId: "981443876533",
      appId: "1:981443876533:web:915ec33bb774dc3790d0fc"
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitLog - Academia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Abre direto na tela de login do app
    );
  }
}