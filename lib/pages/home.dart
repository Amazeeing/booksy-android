import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  void _logUserOut() async {
    await http.post(
        Uri.parse('http://localhost:8080/progetto_TWeb_war_exploded/prenotazioni?action=scollegaUtente'));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
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
          leadingWidth: 100.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            iconSize: 20.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _logUserOut();
              Navigator.popAndPushNamed(context, '/login');
            },
          )
        ],
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(50.0),
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
          label: const Text('Prenota'),
          icon: const Icon(Icons.add),
        ),
      )
    );
  }
}
