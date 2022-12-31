import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';
import 'package:prenotazioni/util/common.dart';
import 'package:prenotazioni/util/appointment_list.dart';

const Map<String, String> _appointmentURL = {
  'studente': 'ottieniStoricoPrenotazioniUtente',
  'amministratore': 'ottieniTuttePrenotazioni'
};

Future<List<Prenotazione>> _fetchAppointments(Utente user) async {
  authenticateUser();

  String appointmentsURL = _appointmentURL[user.ruolo]!;
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
            child: Center(
              child: FutureBuilder<List<Prenotazione>>(
                future: _fetchAppointments(user),
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
                    return AppointmentsList(snapshot.data!, user.ruolo);
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          )
        ]
    );
  }
}
