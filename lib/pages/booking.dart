import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/util/course_selection.dart';
import 'package:prenotazioni/util/tutor_selector.dart';
import 'package:prenotazioni/util/date_selection.dart';

class BookingPage extends StatefulWidget {
  const BookingPage(this.user, {Key? key}) : super(key: key);

  final Utente user;
  static Map<String, String> fields = {};

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final GlobalKey<FormState> _bookingFormKey = GlobalKey<FormState>();

  Future<void> _addAppointment(Map<String, String> fields) async {
    http.post(
        Uri.http('localhost:8080', '/progetto_TWeb_war_exploded/prenotazioni', {
      'action': 'aggiungiPrenotazione',
      'idCorso': fields['course'],
      'emailDocente': fields['tutor'],
      'data': fields['date'],
      'fasciaOraria': fields['time']
    }));
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
            leadingWidth: 100.0),
        body: SafeArea(
          minimum: const EdgeInsets.all(50.0),
          child: Form(
            key: _bookingFormKey,
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
                        CourseSelection(BookingPage.fields),
                        const SizedBox(height: 20.0),
                        Visibility(
                            visible: BookingPage.fields['course'] != null,
                            child: TutorSelection(BookingPage.fields)),
                        const SizedBox(height: 20.0),
                        Visibility(
                            visible: BookingPage.fields['tutor'] != null,
                            child: DateSelection(BookingPage.fields)),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            OutlinedButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                    context, '/'),
                                child: const Text('Annulla')),
                            const SizedBox(width: 20.0),
                            ElevatedButton(
                                onPressed: () {
                                  if(_bookingFormKey.currentState!.validate()) {
                                    _addAppointment(BookingPage.fields);
                                    Navigator.pushReplacementNamed(context, '/');
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
        ));
  }
}
