import 'package:flutter/material.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/pages/home.dart';
import 'package:prenotazioni/pages/login.dart';
import 'package:prenotazioni/util/common.dart';

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
        future: authenticateUser(),
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
