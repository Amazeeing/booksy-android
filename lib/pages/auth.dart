import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/pages/home.dart';
import 'package:prenotazioni/pages/login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  Future<Utente?> _authenticateUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    /* Ottengo gli username e password salvati in precedenza */
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    /* Faccio una chiamata HTTP per autenticare l'utente */
    final response = await http.post(Uri.parse(
        'http://localhost:8080/progetto_TWeb_war_exploded/autentica?action=autenticaUtente'
            '&username=$username&password=$password'));
    String userData = response.body;

    /* Converto la risposta da formato JSON a un oggetto di tipo Utente */
    return _parseUserData(userData);
  }

  Utente _parseUserData(String responseBody) {
    Map<String, dynamic> parsed = jsonDecode(responseBody);

    return Utente.fromJson(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Utente?>(
        future: _authenticateUser(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const LoginPage();
          } else if(snapshot.hasData) {
            return HomePage(snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
      ),
    );
  }
}
