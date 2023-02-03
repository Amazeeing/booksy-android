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
    'action': 'ottieniDocenti'
  }));

  return _parseTutors(response.body);
}

List<Docente> _parseTutors(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Docente>((json) => Docente.fromJson(json)).toList();
}

Future<Map<String, List<String>>> _fetchTutorAvailableSlots(String? tutor, String? date) async {
  if (tutor == null) {
    return {};
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  final response = await http
      .get(Uri.http('localhost:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniSlotDisponibiliDocente',
    'docente': tutor,
    'dataInizio': date ?? '13/02/2023',
    'dataFine': date ?? '17/02/2023'
  }));

  return _parseTutorAvailableSlots(response.body);
}

Map<String, List<String>> _parseTutorAvailableSlots(String responseBody) {
  final Map<String, dynamic> parsed =
      jsonDecode(responseBody) as Map<String, dynamic>;

  Map<String, List<String>> tutorAvailableSlots =
      parsed.map((key, value) => MapEntry(key, List<String>.from(value)));

  return tutorAvailableSlots;
}

class AvailableSlotsPage extends StatefulWidget {
  const AvailableSlotsPage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  State<AvailableSlotsPage> createState() => _AvailableSlotsPageState();
}

class _AvailableSlotsPageState extends State<AvailableSlotsPage> {
  String? selectedTutor, selectedDate;

  List<SlotDisponibile> _buildAvailableSlotsList(
      String? tutor, Map<String, List<String>> slots) {
    List<SlotDisponibile> availableSlots = [];

    for (var slot in slots.entries) {
      for (var timeSlot in slot.value) {
        availableSlots.add(SlotDisponibile(
            docente: tutor!, data: slot.key, fasciaOraria: timeSlot));
      }
    }

    return availableSlots;
  }

  String _parseDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        items: tutors.map((docente) {
                          return DropdownMenuItem<String>(
                            value: docente.email,
                            child: Text('${docente.nome} ${docente.cognome}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTutor = value;
                          });
                        },
                        menuMaxHeight: 200.0,
                      ),
                    ),
                  ],
                );
              } else {
                return const LinearProgressIndicator();
              }
            }),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const Text('Data:'),
            const SizedBox(width: 10.0),
            Expanded(
              child: TextFormField(
                controller: TextEditingController(text: selectedDate),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selezionare una data.';
                  }

                  return null;
                },
                onTap: () async {
                  DateTime today = DateTime.now();
                  DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate: today,
                      firstDate: today,
                      lastDate: today.add(const Duration(days: 7)));

                  if (selected != null) {
                    String parsedDate = _parseDate(selected);
                    setState(() {
                      selectedDate = parsedDate;
                    });
                  }
                },
                decoration:
                    const InputDecoration(suffixIcon: Icon(Icons.calendar_month)),
              ),
            )
          ],
        ),
        const Divider(thickness: 2.0),
        const SizedBox(height: 10.0),
        Expanded(
          child: Center(
              child: FutureBuilder<Map<String, List<String>>>(
                future: _fetchTutorAvailableSlots(selectedTutor, selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
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
                  } else if (snapshot.hasData) {
                    List<SlotDisponibile> tutorAvailableSlots =
                    _buildAvailableSlotsList(selectedTutor, snapshot.data!);
                    return SlotList(
                        tutorAvailableSlots, widget.user.ruolo == 'amministratore');
                  } else {
                    return const CircularProgressIndicator();
                  }
                  },
          )),
        )
      ],
    );
  }
}
