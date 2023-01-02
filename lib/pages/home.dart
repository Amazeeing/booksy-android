import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prenotazioni/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/pages/booking.dart';
import 'package:prenotazioni/pages/history.dart';
import 'package:prenotazioni/model/utente.dart';
import 'package:prenotazioni/util/common.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _logUserOut() async {
    authenticateUser();

    await http.post(Uri.http('localhost:8080/progetto_TWeb_war_exploded',
        '/autentica', {'action': 'scollegaUtente'}));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WelcomePage(widget.user),
      HistoryPage(widget.user)
    ];

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
            tooltip: 'Scollegati',
          )
        ],
      ),
      body: SafeArea(
          minimum: const EdgeInsets.all(50.0),
          child: Center(child: pages.elementAt(_selectedIndex))),
      floatingActionButton: Visibility(
        visible: widget.user.ruolo == 'studente',
        child: FloatingActionButton.extended(
          onPressed: () => {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => BookingPage(widget.user)))
          },
          label: const Text('Prenota'),
          icon: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Storico')
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
