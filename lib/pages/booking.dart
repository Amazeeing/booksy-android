import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/util/course_selection.dart';
import 'package:prenotazioni/util/tutor_selection.dart';
import 'package:prenotazioni/util/date_selection.dart';
import 'package:prenotazioni/util/timeslot_selection.dart';
import 'package:prenotazioni/util/fields_notifier.dart';

final provider =
    StateNotifierProvider<FieldsNotifier, Map<String, String?>>((ref) {
  return FieldsNotifier();
});

class BookingPage extends ConsumerWidget {
  BookingPage({Key? key}) : super(key: key);

  final GlobalKey<FormState> _bookingFormKey = GlobalKey<FormState>();

  Future<void> _addAppointment(Map<String, String?> fields) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    await http
        .post(Uri.http('10.0.2.2:8080', '/progetto_TWeb_war_exploded/mobile', {
      'username': username,
      'password': password,
      'action': 'aggiungiPrenotazione',
      'idCorso': fields['course'],
      'emailDocente': fields['tutor'],
      'data': fields['date'],
      'fasciaOraria': fields['time']
    }));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Image.asset('assets/logo.png', fit: BoxFit.fitWidth),
            ),
            leadingWidth: 100.0),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Form(
            key: _bookingFormKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Prenota una ripetizione',
                    textScaleFactor: 1.5,
                  ),
                  const SizedBox(height: 30.0),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CourseSelection(provider),
                          const SizedBox(height: 10.0),
                          TutorSelection(provider),
                          const SizedBox(height: 10.0),
                          DateSelection(provider),
                          const SizedBox(height: 10.0),
                          TimeSlotSelection(provider),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                  onPressed: () {
                                    ref.read(provider.notifier).clear();
                                    Navigator.pushReplacementNamed(context, '/');
                                  },
                                  child: const Text('Annulla')),
                              ElevatedButton(
                                  onPressed: () {
                                    if (_bookingFormKey.currentState!
                                        .validate()) {
                                      _addAppointment(ref.read(provider));
                                      ref.read(provider.notifier).clear();
                                      Navigator.pushReplacementNamed(
                                          context, '/');
                                    }
                                  },
                                  child: const Text('Prenota'))
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
