import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';
import 'util/appointment_list.dart';

List<Prenotazione> _getDummyAppointments() {
  return <Prenotazione>[
    Prenotazione(
        utente: 'heymehdi',
        corso: 'Matematica',
        docente: 'Ciro Amato',
        data: 'Lunedì',
        fasciaOraria: '15:00 - 16:00',
        attiva: true,
        effettuata: true),
    Prenotazione(
        utente: 'heymehdi',
        corso: 'Musica',
        docente: 'Antonello Perdonò',
        data: 'Venerdì',
        fasciaOraria: '18:00 - 19:00',
        attiva: false,
        effettuata: false),
    Prenotazione(
        utente: 'heymehdi',
        corso: 'Scienze',
        docente: 'Niccolò Spappalardo',
        data: 'Mercoledì',
        fasciaOraria: '16:00 - 17:00',
        attiva: true,
        effettuata: false)
  ];
}

const Map<String, String> _appointmentURL = {
  'studente': 'ottieniPrenotazioniUtente',
  'amministratore': 'ottieniPrenotazioniAttive'
};

Future<List<Prenotazione>> _fetchAppointments(Utente user) async {
  final response = await http.get(Uri.parse(
      'http://localhost:3036/progetto_TWeb_war_exploded/prenotazioni?action=ottieniPrenotazioniUtente' +
          '&utente=' +
          user.username));

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
                  return AppointmentsList(snapshot.data!);
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
