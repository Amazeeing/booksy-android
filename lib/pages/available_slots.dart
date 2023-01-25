import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/docente.dart';
import 'package:prenotazioni/util/slot_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';

Future<List<Docente>> _fetchAvailableTutors() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  /* Autentico l'utente per poter rinnovare la sessione */
  final response = await http
      .get(Uri.http('localhost:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniDocentiLiberi'
  }));

  return _parseTutors(response.body);
}

List<Docente> _parseTutors(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Docente>((json) => Docente.fromJson(json)).toList();
}

Map<String, Map<String, List<String>>> _parseAvailableSlots(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return Map<String, Map<String, List<String>>>.from(parsed);
}

Future<Map<String, Map<String, List<String>>>> _fetchAvailableSlots() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  final response = await http.get(Uri.http('localhost:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniSlotDisponibili',
    'dataInizio': '13/02/2023',
    'dataFine': '17/02/2023'
  }));

  return _parseAvailableSlots(response.body);
}


class SlotCard extends StatelessWidget {
  const SlotCard(this.corso, this.data, this.fasciaOraria, {Key? key}) : super(key: key);

  final String corso, data, fasciaOraria;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridTile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(corso, textScaleFactor: 1.25),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fasciaOraria),
                  const SizedBox(width: 10.0),
                  Text(data,
                      textScaleFactor: 0.75,
                      style: TextStyle(color: Colors.grey[500])
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AvailableSlotsPage extends StatefulWidget {
  const AvailableSlotsPage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  State<AvailableSlotsPage> createState() => _AvailableSlotsPageState();
}

class _AvailableSlotsPageState extends State<AvailableSlotsPage> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Benvenuto ${widget.user.nome}! 👋', textScaleFactor: 1.5),
        const SizedBox(height: 20.0),
        const Text('📅 Ripetizioni disponibili'),
        FutureBuilder<List<Docente>>(
          future: _fetchAvailableTutors(),
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              return const Text('Impossibile reperire i docenti.');
            } else if(snapshot.hasData) {
              List<Docente> tutors = snapshot.data!;
              return Column(
                children: [
                  const Text('Seleziona un docente'),
                  DropdownButton<String>(
                      items: tutors.map((docente) {
                        return DropdownMenuItem<String>(
                          value: docente.email,
                          child: Text('${docente.nome} ${docente.cognome}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selected = value;
                      }
                  ),
                  const Divider(thickness: 2.0),
                  Expanded(
                      child: FutureBuilder<Map<String, Map<String, List<String>>>>(
                        future: _fetchAvailableSlots(),
                        builder: (context, snapshot) {
                          if(snapshot.hasError) {
                            return const Text('Impossibile reperire le ripetizioni disponibili');
                          } else if(snapshot.hasData) {
                            Map<String, List<String>> slots = snapshot.data![selected]!;
                            return SlotList(selected!, slots);
                          } else {
                            return const CircularProgressIndicator();
                          }
                        },
                      )
                  )
                ],
              );
            } else {
              return const LinearProgressIndicator();
            }
          }
        ),
      ],
    );
  }
}
