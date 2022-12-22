import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';
import '../util/appointment_list.dart';

const Map<String, String> _appointmentURL = {
  'studente': 'ottieniPrenotazioniUtente',
  'amministratore': 'ottieniPrenotazioniAttive'
};

Future<List<Prenotazione>> _fetchAppointments(Utente user) async {
  String appointmentsURL = _appointmentURL[user.ruolo]!;
  if(user.ruolo == 'studente') {
    appointmentsURL += '&utente=${user.username}';
  }

  final response = await http.get(Uri.parse(
      'http://localhost:8080/progetto_TWeb_war_exploded/prenotazioni?action=$appointmentsURL'));

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
    return Column(
        children: [
          const Text(
            'Storico delle prenotazioni',
            textScaleFactor: 1.5,
          ),
          const SizedBox(height: 20.0),
          const Divider(thickness: 2.0),
          const SizedBox(height: 20.0),
          Expanded(
            child: FutureBuilder<List<Prenotazione>>(
              future: _fetchAppointments(user),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Impossibile reperire le prenotazioni effettuate.'),
                  );
                } else if (snapshot.hasData) {
                  return AppointmentsList(snapshot.data!, user.ruolo);
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          )
        ]
    );
  }
}
