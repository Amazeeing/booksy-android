import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';
import 'package:prenotazioni/util/appointment_list.dart';

Future<List<Prenotazione>> _fetchAvailableSlots() async {
  /* Chiamata HTTP che ottiene le prenotazioni disponibili */
  final response = await http.get(Uri.parse('localhost' /* sostituire con URL servlet */));

  return _parseAvailableSlots(response.body);
}

List<Prenotazione> _parseAvailableSlots(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed
      .map<Prenotazione>((json) => Prenotazione.fromJson(json))
      .toList();
}

class CataloguePageFuture extends StatelessWidget {
  const CataloguePageFuture({required this.user, Key? key}) : super(key: key);

  final Utente user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Prenotazione>>(
      future: _fetchAvailableSlots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Impossibile reperire le prenotazioni disponibili.'),
          );
        } else if (snapshot.hasData) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Benvenuto ${user.nome}! 👋'),
              const Text('Ecco le tue prenotazioni: '),
              const Divider(thickness: 1.0),
              AppointmentsList(snapshot.data!)
            ],
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

/* Viene mostrata la pagina con gli slot disponibili */
class CataloguePage extends StatelessWidget {
  const CataloguePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [

      ],
    );
  }
}

