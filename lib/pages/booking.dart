import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/util/course_selection.dart';
import 'package:prenotazioni/util/tutor_selector.dart';
import 'package:prenotazioni/util/date_selection.dart';

class BookingPage extends StatelessWidget {
  const BookingPage(this.user, {Key? key}) : super(key: key);

  final Utente user;
  static Map<String, String> fields = {};

  Future<bool> _addAppointment(Map<String, String> fields) async {
    final response = await http.post(Uri.parse('http://localhost:8080/progetto_TWeb_war_exploded/corsi?action=ottieniCorsi'
        '&username=${user.username}&idCorso=${fields['course']}&emailDocente=${fields['tutor']}&data=${fields['date']}&fasciaOraria=${fields['time']}'));

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
                      CourseSelection(fields),
                      const SizedBox(height: 20.0),
                      TutorSelection(fields),
                      const SizedBox(height: 20.0),
                      DateSelection(fields),
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
                                _addAppointment(fields);
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
