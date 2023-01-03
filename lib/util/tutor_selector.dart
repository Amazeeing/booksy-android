import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/docente.dart';

Future<List<Docente>> _fetchTutorsByCourse(String name) async {
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

class TutorSelection extends StatefulWidget {
  TutorSelection(this.fields, {Key? key}) : super(key: key);

  Map<String, String> fields;

  @override
  State<TutorSelection> createState() => _TutorSelectionState();
}

class _TutorSelectionState extends State<TutorSelection> {
  Docente? selected;

  @override
  Widget build(BuildContext context) {
    if (widget.fields['course'] == null) {
      return const Text('Nessun corso selezionato.');
    }

    return FutureBuilder<List<Docente>>(
      future: _fetchTutorsByCourse(widget.fields['course']!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Impossibile reperire i corsi disponibili.');
        } else if (snapshot.hasData) {
          return Column(
            children: [
              const Text('Seleziona un docente'),
              DropdownButtonFormField<Docente>(
                value: selected,
                items: snapshot.data!.map((docente) {
                  return DropdownMenuItem<Docente>(
                    value: docente,
                    child: Text(docente.nome + docente.cognome),
                  );
                }).toList(),
                onChanged: (Docente? value) {
                  selected = value;
                  widget.fields['tutor'] = value!.email;
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              )
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
