import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';

class AuthPage extends StatelessWidget {
  AuthPage(this.username, this.password, {Key? key}) : super(key: key);

  final String username, password;

  Future<Utente> _authenticateUser() async {
    /* Chiamata HTTP per ottenere l'autenticazione dell'utente */
    final response = await http.get(Uri.parse(
        'http://localhost:3036/progetto_TWeb_war_exploded/autentica?action=autenticaUtente' +
        '&username=$username&password=$password'));

    return _parseUserData(response.body);
  }

  Utente _parseUserData(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Utente>((json) => Utente.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Utente>(
        future: _authenticateUser(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return AlertDialog(
              icon: const Icon(Icons.cloud_off),
              title: const Text('Booksy è offline'),
              content: const Text('Per favore riprova più tardi.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK')
                )
              ],
            );
          } else if(snapshot.hasData) {
            Navigator.pushReplacementNamed(context, '/home');
            return const Placeholder();
          } else {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
        }
      ),
    );
  }
}
