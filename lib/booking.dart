import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/model/prenotazione.dart';

import 'util/course_selection.dart';
import 'util/tutor_selector.dart';
import 'util/day_selection.dart';
import 'util/timeslot_selection.dart';

class BookingPage extends StatelessWidget {
  BookingPage({required this.user, Key? key}) : super(key: key);

  final Utente user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<bool> _addAppointment(Prenotazione appointment) async {
    final response = await http.post(Uri.parse('http://localhost:3036/progetto_TWeb_war_exploded/corsi?action=ottieniCorsi' +
        '&username=${user.username}&idCorso=${appointment.corso}&emailDocente=${appointment.docente}&data=${appointment.data}&fasciaOraria=${appointment.fasciaOraria}'));

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Image.asset('assets/logo.png', fit: BoxFit.fitWidth),
          ),
          leadingWidth: 100.0
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CourseSelection(),
                      const SizedBox(height: 20.0),
                      const TutorSelection(),
                      const SizedBox(height: 20.0),
                      const DaySelection(),
                      const SizedBox(height: 20.0),
                      const TimeSlotSelection(),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Annulla')
                          ),
                          const SizedBox(width: 20.0),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Prenota')
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
