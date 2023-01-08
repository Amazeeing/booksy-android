import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/docente.dart';
import 'package:prenotazioni/util/fields_notifier.dart';

Future<List<Docente>> _fetchTutorsByCourse(String? name) async {
  if (name == null) {
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
      'localhost:8080',
      '/progetto_TWeb_war_exploded/docenti',
      {'action': 'filtraDocentePerCorso', 'corso': name}));

  client.close();

  return _parseTutors(response.body);
}

List<Docente> _parseTutors(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Docente>((json) => Docente.fromJson(json)).toList();
}

class TutorSelection extends ConsumerWidget {
  const TutorSelection(this.fieldsProvider, {Key? key}) : super(key: key);

  final StateNotifierProvider<FieldsNotifier, Map<String, String?>>
      fieldsProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String?> fields = ref.watch(fieldsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleziona un docente'),
        const SizedBox(height: 10.0),
        FutureBuilder<List<Docente>>(
          future: _fetchTutorsByCourse(fields['course']),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Impossibile reperire i docenti disponibili.');
            } else if (snapshot.hasData) {
              List<Docente> tutors = snapshot.data!;
              return DropdownButtonFormField<String>(
                disabledHint: fields['course'] != null
                    ? const Text('Nessun docente trovato')
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selezionare un docente.';
                  }

                  return null;
                },
                value: fields['tutor'],
                items: tutors.map((docente) {
                  return DropdownMenuItem<String>(
                    value: docente.email,
                    child: Text('${docente.nome} ${docente.cognome}'),
                  );
                }).toList(),
                onChanged: (value) {
                  ref.read(fieldsProvider.notifier).setTutor(value!);
                },
                menuMaxHeight: 200.0,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        )
      ],
    );
  }
}
