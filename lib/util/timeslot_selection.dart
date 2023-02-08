import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/util/fields_notifier.dart';

Future<List<String>> _fetchAvailableSlots(String? tutor, String? date) async {
  if (tutor == null || date == null) {
    return [];
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  final response = await http
      .get(Uri.http('10.0.2.2:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniSlotDisponibiliDocenteData',
    'docente': tutor,
    'dataInizio': date
  }));

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleziona una fascia oraria'),
        const SizedBox(height: 10.0),
        FutureBuilder<List<String>>(
          future: _fetchAvailableSlots(fields['tutor'], fields['date']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                  'Impossibile reperire le fascie orarie.');
            } else if (snapshot.hasData) {
              List<String> timeSlots = snapshot.data!;
              return DropdownButtonFormField(
                  value: fields['timeSlot'],
                  disabledHint:
                      fields['tutor'] != null && fields['date'] != null
                          ? const Text('Nessuna fascia oraria disponibile',
                              overflow: TextOverflow.fade)
                          : null,
                  items: timeSlots.map((timeSlot) {
                    return DropdownMenuItem<String>(
                      value: timeSlot,
                      child: Text(timeSlot),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(fieldsProvider.notifier).setTime(value!);
                  },
                  menuMaxHeight: 200.0);
            } else {
              return const LinearProgressIndicator();
            }
          },
        )
      ],
    );
  }
}
