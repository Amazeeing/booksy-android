import 'package:flutter/material.dart';

class DaySelection extends StatefulWidget {
  const DaySelection({Key? key}) : super(key: key);

  @override
  State<DaySelection> createState() => _DaySelectionState();
}

class _DaySelectionState extends State<DaySelection> {
  final List<String> _daysList = ['Lunedì', 'Martedì', 'Mercoledì',
    'Giovedì', 'Venerdì'];

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
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder()
          ),
        )
      ],
    );
  }
}