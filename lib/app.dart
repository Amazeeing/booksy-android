import 'package:flutter/material.dart';

import 'package:prenotazioni/pages/auth.dart';
import 'package:prenotazioni/pages/login.dart';
import 'package:prenotazioni/pages/register.dart';
import 'package:prenotazioni/pages/catalogue.dart';

import 'theme.dart';

class AppPrenotazioni extends StatelessWidget {
  const AppPrenotazioni({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Booksy',
      theme: booksyTheme,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => AuthPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/catalogue': (context) => const CataloguePage()
      },
      debugShowCheckedModeBanner: false,
    );
  }
}