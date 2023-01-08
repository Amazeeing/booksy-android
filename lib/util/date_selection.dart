import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:prenotazioni/util/fields_notifier.dart';

class DateSelection extends ConsumerWidget {
  const DateSelection(this.fieldsProvider, {Key? key}) : super(key: key);

  final StateNotifierProvider<FieldsNotifier, Map<String, String?>>
      fieldsProvider;

  String _parseDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Map<String, String?> fields = ref.watch(fieldsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seleziona una data'),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: TextEditingController(text: fields['date']),
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
              ref.read(fieldsProvider.notifier).setDate(parsedDate);
            }
          },
          decoration: const InputDecoration(border: OutlineInputBorder()),
        )
      ],
    );
  }
}
