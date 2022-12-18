import 'package:flutter/material.dart';

import 'auth.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _usernameInput = TextEditingController();
  final _passwordInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => AuthPage(_usernameInput.text, _passwordInput.text)
                    )
                  );
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
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/logo.png', fit: BoxFit.contain),
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
