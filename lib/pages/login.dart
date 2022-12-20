import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _usernameInput = TextEditingController();
  final _passwordInput = TextEditingController();

  Future<Utente> _authenticateUser() async {
    /* Mostro schermata di caricamento */
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );

    /* Ottenimento dei dati inseriti nel form */
    String username, password;
    username = _usernameInput.text;
    password = _passwordInput.text;

    /* Chiamata HTTP per ottenere l'autenticazione dell'utente */
    final response = await http.get(Uri.parse(
        'http://localhost:3036/progetto_TWeb_war_exploded/autentica?action=autenticaUtente'
            '&username=$username&password=$password'));
    String userData = response.body;

    /* Ottenimento della cache locale e scrittura dell'utente per aperture future dell'app */
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('current-user', userData);

    return _parseUserData(userData);
  }

  Utente _parseUserData(String responseBody) {
    Map<String, dynamic> parsed = jsonDecode(responseBody);

    return Utente.fromJson(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
                hintText: 'Username', border: OutlineInputBorder()),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Il campo username non può essere vuoto';
              }

              return null;
            },
            controller: _usernameInput,
          ),
          const SizedBox(height: 12.0),
          TextFormField(
            obscureText: true,
            decoration: const InputDecoration(
                hintText: 'Password', border: OutlineInputBorder()),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Il campo password non può essere vuoto';
              }
              return null;
            },
            controller: _passwordInput,
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _authenticateUser();
                  Navigator.pushReplacementNamed(context, '/auth');
                }
              },
              child: const Text('Accedi')
          ),
          const SizedBox(height: 20.0),
          const Text(
            'Non hai un account?',
          ),
          TextButton(
              onPressed: () => {Navigator.pushNamed(context, '/register')},
              child: const Text('Registrati')
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _usernameInput.dispose();
    _passwordInput.dispose();
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 100.0, horizontal: 125.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Image.asset('assets/logo.png', fit: BoxFit.contain),
          const SizedBox(height: 20.0),
          const Text(
            'Dai un boost alla tua carriera universitaria 🚀',
            maxLines: 2,
            textScaleFactor: 1.5,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 100.0),
          const Text(
            'Effettua l\'accesso',
            textScaleFactor: 1.5,
          ),
          const SizedBox(height: 20.0),
          const LoginForm()
        ]),
      ),
    );
  }
}
