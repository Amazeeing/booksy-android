import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/util/fields_notifier.dart';

Future<Map<String, List<String>>> _fetchAvailableSlots(String tutor) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  http.Client client = http.Client();

  /* Autentico l'utente per poter rinnovare la sessione */
  await client.post(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/autentica',
      {'action': 'autenticaUtente',
        'username': username,
        'password': password}));

  final response = await client.get(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/slot-disponibili',
      {'action': 'ottieniSlotDisponibiliDocente', 'docente': tutor}));

  client.close();

  return _parseAvailableSlots(response.body);
}

Map<String, List<String>> _parseAvailableSlots(String responseBody) {
  Map<String, dynamic> availableSlots = jsonDecode(responseBody);

  return availableSlots as Map<String, List<String>>;
}

class DateSelection extends ConsumerWidget {
  const DateSelection(this.fieldsProvider, {Key? key}) : super(key: key);

  final StateNotifierProvider<FieldsNotifier, Map<String, String?>> fieldsProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String?> fields = ref.watch(fieldsProvider);

    if(fields['tutor'] == null) {
      return const Text('Nessun docente selezionato.');
    }

    return FutureBuilder<Map<String, List<String>>>(
        future: _fetchAvailableSlots(fields['tutor']!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Text(
                'Impossibile reperire le fascie orarie per il docente selezionato.');
          } else if (snapshot.hasData) {
            Map<String, List<String>> timeSlots = snapshot.data!;
            return Column(
              children: [
                const Text('Seleziona una data'),
                const SizedBox(height: 10.0),
                  DropdownButtonFormField<String>(
                    value: fields['date'],
                    items: timeSlots.keys
                        .map<DropdownMenuItem<String>>((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      ref.read(fieldsProvider.notifier).setDate(value!);
                    },
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                const SizedBox(height: 20.0),
                const Text('Seleziona una fascia oraria'),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: fields['time'],
                  items:
                      timeSlots[fields['date']]!.map((String timeSlot) {
                    return DropdownMenuItem<String>(
                      value: timeSlot,
                      child: Text(timeSlot),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    ref.read(fieldsProvider.notifier).setTime(value!);
                  },
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                )
              ],
            );
          } else {
            return const LinearProgressIndicator();
          }
        });
  }
}
