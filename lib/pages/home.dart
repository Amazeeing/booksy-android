import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prenotazioni/pages/available_slots.dart';
import 'package:prenotazioni/pages/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:prenotazioni/pages/booking.dart';
import 'package:prenotazioni/pages/history.dart';
import 'package:prenotazioni/model/utente.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.user, {Key? key}) : super(key: key);

  final Utente user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _logUserOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    await http.post(Uri.http(
        '10.0.2.2:8080', 'progetto_TWeb_war_exploded/autentica', {
      'username': username,
      'password': password,
      'action': 'scollegaUtente'
    }));

    prefs.clear();
  }



  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      AvailableSlotsPage(widget.user),
      HistoryPage(widget.user)
    ];

    List<BottomNavigationBarItem> navigationBarItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Disponibilità'),
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Storico')
    ];

    if (widget.user.ruolo == 'studente') {
      pages.insert(0, WelcomePage(widget.user));
      navigationBarItems.insert(
          0, const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'));
    }

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
          minimum: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50.0),
          child: Center(child: pages.elementAt(_selectedIndex))),
      floatingActionButton: Visibility(
        visible: widget.user.ruolo == 'studente',
        child: FloatingActionButton.extended(
          onPressed: () => {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => BookingPage()))
          },
          label: const Text('Prenota'),
          icon: const Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navigationBarItems,
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
