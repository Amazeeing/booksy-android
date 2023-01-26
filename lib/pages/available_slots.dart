import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/docente.dart';
import 'package:prenotazioni/model/slot_disponibile.dart';
import 'package:prenotazioni/util/slot_list.dart';

Future<List<Docente>> _fetchAvailableTutors() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  /* Autentico l'utente per poter rinnovare la sessione */
  final response = await http.get(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/mobile', {
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

Map<String, Map<String, List<String>>> _parseAvailableSlots(
    String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return Map<String, Map<String, List<String>>>.from(parsed);
}

Future<Map<String, Map<String, List<String>>>> _fetchAvailableSlots() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  final response = await http
      .get(Uri.http('localhost:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniSlotDisponibili',
    'dataInizio': '13/02/2023',
    'dataFine': '17/02/2023'
  }));

  return _parseAvailableSlots(response.body);
}

class SlotCard extends StatelessWidget {
  const SlotCard(this.corso, this.data, this.fasciaOraria, {Key? key})
      : super(key: key);

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
                      style: TextStyle(color: Colors.grey[500]))
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

  List<SlotDisponibile> _buildAvailableSlotsList(String? tutor, Map<String, List<String>> slots) {
    List<SlotDisponibile> availableSlots = [];

    for (var slot in slots.entries) {
      for (var timeSlot in slot.value) {
        availableSlots.add(SlotDisponibile(
            docente: tutor!, data: slot.key, fasciaOraria: timeSlot)
        );
      }
    }

    return availableSlots;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('📅 Ripetizioni disponibili', textScaleFactor: 1.5),
        const SizedBox(height: 20.0),
        FutureBuilder<List<Docente>>(
            future: _fetchAvailableTutors(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Impossibile reperire i docenti.');
              } else if (snapshot.hasData) {
                List<Docente> tutors = snapshot.data!;
                return Row(
                  children: [
                    const Text('Docente:'),
                    const SizedBox(width: 10.0),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: 500.0,
                          maxHeight: 50.0
                      ),
                      child: DropdownButtonFormField<String>(
                        items: tutors.map((docente) {
                          return DropdownMenuItem<String>(
                            value: docente.email,
                            child: Text('${docente.nome} ${docente.cognome}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selected = value;
                          });
                        },
                        menuMaxHeight: 200.0,
                      ),
                    )
                  ],
                );
              } else {
                return const LinearProgressIndicator();
              }
            }),
        const SizedBox(height: 10.0),
        const Divider(thickness: 2.0),
        const SizedBox(height: 10.0),
        Expanded(
          child: Center(
              child: FutureBuilder<Map<String, Map<String, List<String>>>>(
                future: _fetchAvailableSlots(),
                builder: (context, snapshot) {
                  if(snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(Icons.question_mark_sharp, size: 80),
                        SizedBox(height: 10.0),
                        Text(
                          'Impossibile reperire le ripetizioni disponibili.\nRiprova più tardi.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  } else if(snapshot.hasData) {
                    List<SlotDisponibile> tutorAvailableSlots = _buildAvailableSlotsList(selected, snapshot.data![selected]!);
                    return SlotList(tutorAvailableSlots);
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              )
          ),
        )
      ],
    );
  }
}
