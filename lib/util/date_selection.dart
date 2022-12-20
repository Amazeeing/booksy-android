import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Map<String, List<String>>> _fetchAvailableSlots() async {
  final response = await http.get(
      Uri.parse('http://localhost:3036/progetto_TWeb_war_exploded/slot-disponibili?action=ottieniSlotDisponibiliDocente'));

  return _parseAvailableSlots(response.body);
}

_parseAvailableSlots(String responseBody) {
  Map<String, dynamic> availableSlots = jsonDecode(responseBody);

  // TODO: trovare un modo per fare il parsing della hashmap su Flutter
}

class DateSelection extends StatefulWidget {
  DateSelection(this.fields, {Key? key}) : super(key: key);

  Map<String, String> fields;

  @override
  State<DateSelection> createState() => _DateSelectionState();
}

class _DateSelectionState extends State<DateSelection> {
  final List<String> _daysList = ['Lunedì', 'Martedì', 'Mercoledì', 'Giovedì', 'Venerdì'];
  final List<String> _timeSlots = ['15:00 - 16:00', '16:00 - 17:00', '18:00 - 19:00'];

  String? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Seleziona una data'),
        DropdownButtonFormField<String>(
          items: _daysList.map<DropdownMenuItem<String>>((String day) {
            return DropdownMenuItem<String>(
              value: day,
              child: Text(day),
            );
          }).toList(),
          onChanged: (String? value) {
            selected = value!;
            widget.fields['date'] = value;
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder()
          ),
        ),
        const Text('Seleziona una fascia oraria'),
        DropdownButtonFormField<String>(
          items: _timeSlots.map((String timeSlot) {
            return DropdownMenuItem<String>(
              value: timeSlot,
              child: Text(timeSlot),
            );
          }).toList(),
          onChanged: (String? value) {
            selected = value!;
            widget.fields['time'] = value;
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder()
          ),
        )
      ],
    );
  }
}