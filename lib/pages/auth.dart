import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/pages/home.dart';
import 'package:prenotazioni/pages/login.dart';

Future<Utente?> _authenticateUser() async {
  /* Ottengo un istanza della memoria locale */
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  /* Ottengo gli username e password salvati in precedenza */
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');
  if(username == null || password == null) {
    return null;
  }

  final http.Response response;
  try {
    response = await http.post(Uri.http(
        'localhost:8080', '/progetto_TWeb_war_exploded/autentica',
        {'action': 'autenticaUtente',
          'username': username,
          'password': password}));
  } catch (e) {
    throw Exception('Impossibile comunicare con Booksy: riprovare più tardi.');
  }

  String userData = response.body;
  if(userData == 'null') {
    throw Exception('Credenziali errate: per favore riprova.');
  }

  /* Converto la risposta da formato JSON a un oggetto di tipo Utente */
  return _parseUserData(userData);
}

Utente _parseUserData(String responseBody) {
  Map<String, dynamic> parsed = jsonDecode(responseBody);

  return Utente.fromJson(parsed);
}

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Utente?>(
        future: _authenticateUser(),
        builder: (context, snapshot) {
          if(snapshot.hasError || snapshot.data == null) {
            String? loginError = (snapshot.data != null) ? snapshot.error.toString() : null;
            return LoginPage(error: loginError);
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
