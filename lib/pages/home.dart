import 'package:flutter/material.dart';

import 'package:prenotazioni/pages/booking.dart';
import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/pages/history.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          minimum: EdgeInsets.all(50.0),
          child: Center(
            child: HistoryPage(widget.user)
          )
      ),
      floatingActionButton: Visibility(
        visible: widget.user.ruolo == 'studente',
        child: FloatingActionButton.extended(
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingPage(widget.user))
            )
          },
          label: Text('Prenota'),
          icon: Icon(Icons.add),
        ),
      )
    );
  }
}
