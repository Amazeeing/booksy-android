import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({this.error, Key? key}) : super(key: key);

  final String? error;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _usernameInput = TextEditingController();
  final _passwordInput = TextEditingController();

  void _saveCredentials() async {
    /* Ottenimento dei dati inseriti nel form */
    String username, password;
    username = _usernameInput.text;
    password = _passwordInput.text;

    /* Ottenimento della cache locale e scrittura delle credenziali per aperture future dell'app */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
    prefs.setString('password', password);
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
                return 'Il campo username non può essere vuoto.';
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
                return 'Il campo password non può essere vuoto.';
              }
              return null;
            },
            controller: _passwordInput,
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveCredentials();
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: const Text('Accedi')),
          const SizedBox(height: 20.0),
          const Text(
            'Non hai un account?',
          ),
          TextButton(
              onPressed: () => {Navigator.pushNamed(context, '/register')},
              child: const Text('Registrati')),
          Text(
            'Si è verificato un\'errore durante l\'accesso: ${widget.error}. Riprovare',
            maxLines: 3,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
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
  const LoginPage({this.error, Key? key}) : super(key: key);

  final String? error;

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
              LoginForm(error: error)
            ]),
      ),
    );
  }
}
