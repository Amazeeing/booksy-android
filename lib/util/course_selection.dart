import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/corso.dart';
import 'package:prenotazioni/util/fields_notifier.dart';

Future<List<Corso>> _fetchCourses() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  /* Autentico l'utente per poter rinnovare la sessione */
  final response = await http.get(Uri.http(
      '10.0.2.2:8080',
      'progetto_TWeb_war_exploded/mobile',
      {'username': username, 'password': password, 'action': 'ottieniCorsiAttivi'}));
  return _parseCourses(response.body);
}

List<Corso> _parseCourses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Corso>((json) => Corso.fromJson(json)).toList();
}

class CourseSelection extends ConsumerWidget {
  const CourseSelection(this.fieldsProvider, {Key? key}) : super(key: key);

  final StateNotifierProvider<FieldsNotifier, Map<String, String?>>
      fieldsProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String?> fields = ref.watch(fieldsProvider);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Seleziona un corso'),
      const SizedBox(height: 10.0),
      FutureBuilder<List<Corso>>(
        future: _fetchCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Impossibile reperire i corsi disponibili.');
          } else if (snapshot.hasData) {
            List<Corso> courses = snapshot.data!;
            return DropdownButtonFormField<String>(
                value: fields['course'],
                disabledHint: const Text('Nessun corso trovato'),
                items: courses.map((corso) {
                  return DropdownMenuItem<String>(
                    value: corso.nome,
                    child: Text(corso.nome),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selezionare un corso.';
                  }

                  return null;
                },
                onChanged: (value) {
                  ref.read(fieldsProvider.notifier).setCourse(value!);
                },
                menuMaxHeight: 200.0
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
      )
    ]);
  }
}
