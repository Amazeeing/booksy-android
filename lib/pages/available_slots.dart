import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/docente.dart';
import 'package:prenotazioni/model/corso.dart';
import 'package:prenotazioni/model/slot_disponibile.dart';
import 'package:prenotazioni/util/slot_list.dart';

final tutorFilterProvider = StateProvider<Docente?>((ref) => null);
final dateFilterProvider = StateProvider<String?>((ref) => null);
final courseFilterProvider = StateProvider<String?>((ref) => null);

final availableSlotsProvider =
    FutureProvider<List<SlotDisponibile>>((ref) async {
  Docente? tutorFilter;
  String? dateFilter;

  tutorFilter = ref.watch(tutorFilterProvider);
  dateFilter = ref.watch(dateFilterProvider);

  if(tutorFilter == null) {
    return [];
  } else {
    Map<String, List<String>> availableSlots =
    await _fetchTutorAvailableSlots(tutorFilter.email, dateFilter);

    return _buildAvailableSlotsList('${tutorFilter.nome} ${tutorFilter.cognome}', availableSlots);
  }
});

List<SlotDisponibile> _buildAvailableSlotsList(
    String tutor, Map<String, List<String>> slots) {
  List<SlotDisponibile> availableSlots = [];

  for (var slot in slots.entries) {
    for (var timeSlot in slot.value) {
      availableSlots.add(SlotDisponibile(
          docente: tutor, data: slot.key, fasciaOraria: timeSlot));
    }
  }

  return availableSlots;
}

Future<Map<String, List<String>>> _fetchTutorAvailableSlots(
    String tutor, String? date) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  final response = await http
      .get(Uri.http('10.0.2.2:8080', '/progetto_TWeb_war_exploded/mobile', {
    'username': username,
    'password': password,
    'action': 'ottieniSlotDisponibiliDocente',
    'docente': tutor,
    'dataInizio': date ?? '13/02/2023',
    'dataFine': date ?? '17/02/2023'
  }));

  return _parseTutorAvailableSlots(response.body);
}

Map<String, List<String>> _parseTutorAvailableSlots(String responseBody) {
  final Map<String, dynamic> parsed =
      jsonDecode(responseBody) as Map<String, dynamic>;

  Map<String, List<String>> tutorAvailableSlots =
      parsed.map((key, value) => MapEntry(key, List<String>.from(value)));

  return tutorAvailableSlots;
}

class TutorFilter extends ConsumerWidget {
  const TutorFilter({Key? key}) : super(key: key);

  Future<List<Docente>> _fetchAvailableTutors(String? course) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    /* Autentico l'utente per poter rinnovare la sessione */
    final response = await http.get(Uri.http(
        '10.0.2.2:8080', '/progetto_TWeb_war_exploded/mobile', {
      'username': username,
      'password': password,
      'action': course != null ? 'filtraDocentePerCorso' : 'ottieniDocenti',
      'corso': course
    }));

    return _parseTutors(response.body);
  }

  List<Docente> _parseTutors(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Docente>((json) => Docente.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Docente? chosenTutor = ref.watch(tutorFilterProvider);
    String? chosenCourse = ref.watch(courseFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Docente: '),
        const SizedBox(height: 10.0),
        FutureBuilder<List<Docente>>(
            future: _fetchAvailableTutors(chosenCourse),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Impossibile reperire i docenti.');
              } else if (snapshot.hasData) {
                List<Docente> tutors = snapshot.data!;
                return DropdownButtonFormField<Docente>(
                  value: chosenTutor,
                  items: tutors.map((docente) {
                    return DropdownMenuItem<Docente>(
                      value: docente,
                      child: Text('${docente.nome} ${docente.cognome}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(tutorFilterProvider.notifier).state = value;
                  },
                  menuMaxHeight: 200.0,
                );
              } else {
                return const LinearProgressIndicator();
              }
            })
      ],
    );
  }
}

class DateFilter extends ConsumerWidget {
  const DateFilter({Key? key}) : super(key: key);

  String _parseDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? chosenDate = ref.watch(dateFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data:'),
        const SizedBox(height: 10.0),
        TextFormField(
          controller: TextEditingController(text: chosenDate),
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
                lastDate: today.add(const Duration(days: 6)));

            if (selected != null) {
              String parsedDate = _parseDate(selected);
              ref.read(dateFilterProvider.notifier).state = parsedDate;
            }
          },
          decoration:
              const InputDecoration(suffixIcon: Icon(Icons.calendar_month)),
        )
      ],
    );
  }
}

class CourseFilter extends ConsumerWidget {
  const CourseFilter({Key? key}) : super(key: key);

  Future<List<Corso>> _fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    /* Autentico l'utente per poter rinnovare la sessione */
    final response = await http.get(Uri.http(
        '10.0.2.2:8080',
        'progetto_TWeb_war_exploded/mobile',
        {'username': username, 'password': password, 'action': 'ottieniCorsiAttivi'}));
    return _parseCourses(response.body);
  }

  List<Corso> _parseCourses(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Corso>((json) => Corso.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? chosenCourse = ref.watch(courseFilterProvider);

    return FutureBuilder<List<Corso>>(
      future: _fetchCourses(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Impossibile reperire i corsi');
        } else if (snapshot.hasData) {
          List<Corso> courses = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Corso:'),
              const SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: chosenCourse,
                items: courses.map((corso) {
                  return DropdownMenuItem<String>(
                    value: corso.nome,
                    child: Text(corso.nome),
                  );
                }).toList(),
                onChanged: (String? value) {
                  ref.read(tutorFilterProvider.notifier).state = null;
                  ref.read(courseFilterProvider.notifier).state = value;
                },
              ),
            ],
          );
        } else {
          return const LinearProgressIndicator();
        }
      },
    );
  }
}

class FiltersPopUp extends ConsumerWidget {
  const FiltersPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 150.0, horizontal: 50.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filtri', textScaleFactor: 1.5),
              const SizedBox(height: 10.0),
              const Divider(thickness: 2.0),
              const SizedBox(height: 10.0),
              const TutorFilter(),
              const SizedBox(height: 10.0),
              const DateFilter(),
              const SizedBox(height: 10.0),
              const CourseFilter(),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text('PULISCI'),
                    onPressed: () {
                      ref.read(tutorFilterProvider.notifier).state = null;
                      ref.read(dateFilterProvider.notifier).state = null;
                      ref.read(courseFilterProvider.notifier).state = null;
                    },
                  ),
                  const SizedBox(width: 10.0),
                  TextButton(
                    child: const Text('CONFERMA'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AvailableSlotsPage extends ConsumerWidget {
  const AvailableSlotsPage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<SlotDisponibile>> availableSlotsListing =
        ref.watch(availableSlotsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('📅 Ripetizioni disponibili', textScaleFactor: 1.5),
        const SizedBox(height: 20.0),
        TextButton.icon(
          icon: const Icon(Icons.filter_alt_outlined),
          label: const Text('Filtri'),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const FiltersPopUp(),
          ),
        ),
        const SizedBox(height: 10.0),
        const Divider(thickness: 2.0),
        const SizedBox(height: 10.0),
        Expanded(
          child: Center(
              child: availableSlotsListing.when(
            data: (slots) => SlotList(slots, user.ruolo == 'amministratore'),
            error: (error, stackTrace) => const Text(
              'Impossibile reperire gli slot disponibili per i parametri selezionati.\nSeleziona Filtri per modificarli.',
            ),
            loading: () => const CircularProgressIndicator(),
          )),
        )
      ],
    );
  }
}
