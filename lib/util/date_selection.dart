import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, List<String>>> _fetchAvailableSlots() async {
  final response = await http.get(Uri.http(
      'localhost:8080', '/progetto_TWeb_war_exploded/slot-disponibili',
      {'action': 'ottieniSlotDisponibiliDocente'}));

  return _parseAvailableSlots(response.body);
}

Map<String, List<String>> _parseAvailableSlots(String responseBody) {
  Map<String, dynamic> availableSlots = jsonDecode(responseBody);

  return availableSlots as Map<String, List<String>>;
}

class DateSelection extends StatefulWidget {
  DateSelection(this.fields, {Key? key}) : super(key: key);

  Map<String, String> fields;

  @override
  State<DateSelection> createState() => _DateSelectionState();
}

class _DateSelectionState extends State<DateSelection> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, List<String>>>(
        future: _fetchAvailableSlots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
                'Impossibile reperire le fascie orarie per il docente selezionato.');
          } else if (snapshot.hasData) {
            Map<String, List<String>> timeSlots = snapshot.data!;
            return Column(
              children: [
                const Text('Seleziona una data'),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  items: timeSlots.keys
                      .map<DropdownMenuItem<String>>((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    selected = value!;
                    widget.fields['date'] = value;
                  },
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20.0),
                const Text('Seleziona una fascia oraria'),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  items:
                      timeSlots[widget.fields['date']]!.map((String timeSlot) {
                    return DropdownMenuItem<String>(
                      value: timeSlot,
                      child: Text(timeSlot),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    selected = value!;
                    widget.fields['time'] = value;
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
