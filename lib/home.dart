import 'package:flutter/material.dart';
import 'package:prenotazioni/booking.dart';

import 'history.dart';
import 'catalogue.dart';

import 'package:prenotazioni/model/utente.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Utente user = ModalRoute.of(context)!.settings.arguments as Utente;
    List<Widget> options = [CataloguePage(), HistoryPage(user)];

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
          child: Center(
            child: options.elementAt(_selectedIndex),
          )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Catalogo'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Storico'
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: Visibility(
        visible: user.ruolo == 'studente',
        child: FloatingActionButton.extended(
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingPage(user: user))
            )
          },
          label: Text('Prenota'),
          icon: Icon(Icons.add),
        ),
      )
    );
  }
}
