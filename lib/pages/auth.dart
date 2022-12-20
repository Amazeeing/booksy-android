import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';

import 'package:prenotazioni/pages/home.dart';
import 'package:prenotazioni/pages/login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  Future<Utente?> _getLoggedUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String userData = prefs.getString('current_user')!;

    Utente user = jsonDecode(userData) as Utente;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Utente?>(
        future: _getLoggedUser(),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return HomePage(snapshot.data!);
          } else {
            return const LoginPage();
          }
        }
      ),
    );
  }
}
