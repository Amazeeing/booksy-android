import 'package:flutter/material.dart';

class TimeSlotSelection extends StatefulWidget {
  const TimeSlotSelection({Key? key}) : super(key: key);

  @override
  State<TimeSlotSelection> createState() => _TimeSlotSelectionState();
}

class _TimeSlotSelectionState extends State<TimeSlotSelection> {
  final List<String> _timeSlots = ['15:00 - 16:00', '16:00 - 17:00', '17:00 - 18:00', '18:00 - 19:00'];

  late String dropdownValue = _timeSlots.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Seleziona una fascia oraria'),
        DropdownButtonFormField<String>(
          items: _timeSlots.map((String timeSlot) {
            return DropdownMenuItem<String>(
              value: timeSlot,
              child: Text(timeSlot),
            );
          }).toList(),
          onChanged: (String? value) {
            dropdownValue = value!;
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder()
          ),
        )
      ],
    );
  }
}