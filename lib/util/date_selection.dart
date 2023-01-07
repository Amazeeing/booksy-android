import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prenotazioni/util/fields_notifier.dart';

class DateSelection extends StatefulWidget {
  const DateSelection(this.fieldsProvider, {Key? key}) : super(key: key);

  final StateNotifierProvider<FieldsNotifier, Map<String, String?>>
      fieldsProvider;

  @override
  State<DateSelection> createState() => _DateSelectionState();
}

class _DateSelectionState extends State<DateSelection> {
  final _dateInput = TextEditingController();

  String _parseDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleziona una data'),
        const SizedBox(height: 10.0),
        Consumer(
          builder: (context, ref, child) {
            return TextFormField(
              controller: _dateInput,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selezionare una data.';
                }

                return null;
              },
              onTap: () async {
                DateTime today = DateTime.now();
                DateTime? selected = await showDatePicker(
                    context: context,
                    initialDate: today,
                    firstDate: today,
                    lastDate: today.add(const Duration(days: 7)));

                if (selected != null) {
                  String parsedDate = _parseDate(selected);
                  ref.read(widget.fieldsProvider.notifier).setDate(parsedDate);
                  _dateInput.text = parsedDate;
                }
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            );
          },
        )
      ],
    );
  }
}
