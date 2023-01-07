import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/util/fields_notifier.dart';

Future<List<String>> _fetchAvailableSlots(String? tutor, String? date) async {
  if(tutor == null || date == null) {
    return [];
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  http.Client client = http.Client();

  /* Autentico l'utente per poter rinnovare la sessione */
  await client.post(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/autentica', {
    'action': 'autenticaUtente',
    'username': username,
    'password': password
  }));

  final response = await client.get(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/slot-disponibili', {
    'action': 'ottieniSlotDisponibiliDocente',
    'docente': tutor,
    'dataInizio': date
  }));

  client.close();

  return _parseAvailableSlots(response.body);
}

List<String> _parseAvailableSlots(String responseBody) {
  List<dynamic> parsed = jsonDecode(responseBody);

  return List<String>.from(parsed);
}

class TimeSlotSelection extends ConsumerWidget {
  const TimeSlotSelection(this.fieldsProvider, {Key? key}) : super(key: key);

  final StateNotifierProvider<FieldsNotifier, Map<String, String?>>
      fieldsProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String?> fields = ref.watch(fieldsProvider);

    return FutureBuilder<List<String>>(
        future: _fetchAvailableSlots(fields['tutor'], fields['date']),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
                'Impossibile reperire le fascie orarie per il docente selezionato.');
          } else if (snapshot.hasData) {
            List<String> timeSlots = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seleziona una fascia oraria'),
                const SizedBox(height: 10.0),
                DropdownButtonFormField(
                  value: fields['timeSlot'],
                    items: timeSlots.map((timeSlot) {
                      return DropdownMenuItem<String>(
                        value: timeSlot,
                        child: Text(timeSlot),
                      );
                    }).toList(),
                    onChanged: (value) {
                      ref.read(fieldsProvider.notifier).setTime(value!);
                    },
                  menuMaxHeight: 200.0,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder()
                  ),
                )
              ],
            );
          } else {
            return const LinearProgressIndicator();
          }
        });
  }
}
