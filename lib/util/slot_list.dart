import 'package:flutter/material.dart';
import 'package:prenotazioni/model/slot_disponibile.dart';
import 'package:prenotazioni/pages/booking.dart';

class SlotCard extends StatelessWidget {
  const SlotCard(this.current, {Key? key}) : super(key: key);

  final SlotDisponibile current;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridTile(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(current.data),
                  const SizedBox(width: 10.0),
                  Text(current.fasciaOraria,
                      textScaleFactor: 0.75,
                      style: TextStyle(color: Colors.grey[500])
                  )
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: ElevatedButton(
                  onPressed: () => {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage()))
                  },
                  child: const Text('Prenota'))
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SlotList extends StatelessWidget {
  const SlotList(this.slots, {Key? key}) : super(key: key);

  final List<SlotDisponibile> slots;

  @override
  Widget build(BuildContext context) {
    if(slots.isEmpty) {
      return const Text('Nessuna ripetizione disponibile per il docente selezionato.');
    }

    return GridView.builder(
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
          childAspectRatio: 3.5 / 2.25,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0
        ),
        itemBuilder: (context, index) {
          return SlotCard(slots[index]);
        }
    );
  }
}
