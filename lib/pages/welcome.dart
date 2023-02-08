import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';
import 'package:prenotazioni/util/appointment_list.dart';

Future<List<Prenotazione>> _fetchImminentAppointments(Utente user) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  final response = await http
      .get(Uri.http('10.0.2.2:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniPrenotazioniUtenteImminenti'
  }));

  return _parseAppointments(response.body);
}

List<Prenotazione> _parseAppointments(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<Prenotazione>((json) => Prenotazione.fromJson(json))
      .toList();
}

class WelcomePage extends StatelessWidget {
  const WelcomePage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Benvenuto ${user.nome}! 👋', textScaleFactor: 1.5),
        const SizedBox(height: 20.0),
        const Text('Ecco le tue prenotazioni imminenti:', textScaleFactor: 1.2),
        const SizedBox(height: 10.0),
        const Divider(thickness: 2.0),
        const SizedBox(height: 10.0),
        Expanded(
          child: FutureBuilder<List<Prenotazione>>(
              future: _fetchImminentAppointments(user),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.question_mark_sharp, size: 80),
                      SizedBox(height: 10.0),
                      Text(
                        'Impossibile reperire le prenotazioni imminenti.\nRiprova più tardi.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  return AppointmentsList(snapshot.data!, user.ruolo == 'amministratore');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
        )
      ],
    );
  }
}
