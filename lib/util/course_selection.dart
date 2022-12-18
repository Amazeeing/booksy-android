import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/corso.dart';

Future<List<Corso>> _fetchCourses() async {
  final response = await http.get(
      Uri.parse('http://localhost:3036/progetto_TWeb_war_exploded/corsi?action=ottieniCorsi'));

  return _parseCourses(response.body);
}

List<Corso> _parseCourses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Corso>((json) => Corso.fromJson(json)).toList();
}

class CourseSelection extends StatefulWidget {
  const CourseSelection({Key? key}) : super(key: key);

  @override
  State<CourseSelection> createState() => _CourseSelectionState();
}

class _CourseSelectionState extends State<CourseSelection> {
  Corso? selected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Corso>>(
        future: _fetchCourses(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const Text('Impossibile reperire i corsi disponibili.');
          } else if (snapshot.hasData) {
            return Column(
              children: [
                const Text('Seleziona un corso'),
                DropdownButtonFormField<Corso>(
                  value: selected,
                  items: snapshot.data!.map((corso) {
                    return DropdownMenuItem<Corso>(
                      value: corso,
                      child: Text(corso.nome),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selected = value;
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder()
                  )
                )
              ]
            );
          } else {
            return const LinearProgressIndicator();
          }
        },
    );
  }
}