import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prenotazioni/model/corso.dart';

import 'package:prenotazioni/model/docente.dart';

Future<List<Docente>> _fetchTutorsByCourse(Corso course) async {
  final response = await http.get(
      Uri.parse('http://localhost:3036/progetto_TWeb_war_exploded/docenti?action=filtraDocentePerCorso' +
                '&corso=' + course.nome));

  return _parseTutors(response.body);
}

List<Docente> _parseTutors(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Docente>((json) => Docente.fromJson(json)).toList();
}


class TutorSelection extends StatefulWidget {
  const TutorSelection({this.previousChoice, Key? key}) : super(key: key);

  final Corso? previousChoice;

  @override
  State<TutorSelection> createState() => _TutorSelectionState();
}

class _TutorSelectionState extends State<TutorSelection> {
  Docente? selected;

  @override
  Widget build(BuildContext context) {
    if(widget.previousChoice == null) {
      return const Text('Nessun corso selezionato.');
    }

    return FutureBuilder<List<Docente>>(
      future: _fetchTutorsByCourse(widget.previousChoice!),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
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
                    child: Text(docente.nome),
                  );
                }).toList(),
                onChanged: (Docente? value) {
                  selected = value!;
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder()
                ),
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