import 'package:flutter/material.dart';
import 'package:prenotazioni/model/slot_disponibile.dart';
import 'package:prenotazioni/pages/booking.dart';

class SlotCard extends StatelessWidget {
  const SlotCard(this.current, this.isAdmin, {Key? key}) : super(key: key);

  final SlotDisponibile current;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final Widget appointButton = ElevatedButton(
        onPressed: () => {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => BookingPage()))
            },
        child: const Text('Prenota'));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridTile(
          footer: Visibility(
            visible: isAdmin == false,
              child: Align(
                  alignment: Alignment.centerRight, child: appointButton)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current.docente),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(current.data),
                  const SizedBox(width: 10.0),
                  Text(current.fasciaOraria,
                      textScaleFactor: 0.75,
                      style: TextStyle(color: Colors.grey[500]))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SlotList extends StatelessWidget {
  const SlotList(this.slots, this.isAdmin, {Key? key}) : super(key: key);

  final List<SlotDisponibile> slots;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Text(
          'Nessuna ripetizione disponibile per il docente selezionato.',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey)
      );
    }

    return GridView.builder(
      itemCount: slots.length,
      itemBuilder: (context, index) {
        return SlotCard(slots[index], isAdmin);
      },
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350.0,
          childAspectRatio: 3.0 / 1.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0),
    );
  }
}
