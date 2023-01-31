import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';
import 'package:prenotazioni/util/appointment_list.dart';

/* Una map per legare il ruolo dell'utente all'URL dove ottenere
le prenotazioni a esso rilevanti */
const Map<String, String> _appointmentURL = {
  'studente': 'ottieniStoricoPrenotazioniUtente',
  'amministratore': 'ottieniTuttePrenotazioni'
};

Future<List<Prenotazione>> _fetchAppointments(String userRole) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  /* Ottengo le prenotazioni rilevanti al ruolo dell'utente */
  String appointmentsURL = _appointmentURL[userRole]!;
  final response = await http.get(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/mobile',
      {'username': username,
        'password': password,
        'action': appointmentsURL}));

  /* Faccio il parsing da JSON a una lista contenente oggetti di tipo Prenotazione */
  return _parseAppointments(response.body);
}

List<Prenotazione> _parseAppointments(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<Prenotazione>((json) => Prenotazione.fromJson(json))
      .toList();
}

/* Viene mostrata una pagina con le prenotazioni effettuate */
class HistoryPage extends StatelessWidget {
  const HistoryPage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text(
        '🕖 Storico prenotazioni',
        textScaleFactor: 1.5,
      ),
      const SizedBox(height: 20.0),
      const Divider(thickness: 2.0),
      const SizedBox(height: 20.0),
      Expanded(
        child: Center(
          child: FutureBuilder<List<Prenotazione>>(
            future: _fetchAppointments(user.ruolo),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(Icons.question_mark_sharp, size: 80),
                    SizedBox(height: 10.0),
                    Text(
                      'Impossibile reperire le prenotazioni effettuate.\nRiprova più tardi.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              } else if (snapshot.hasData) {
                return AppointmentsList(snapshot.data!, user.ruolo == 'amministratore');
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      )
    ]);
  }
}
