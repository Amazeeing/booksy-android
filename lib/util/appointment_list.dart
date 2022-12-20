import 'package:flutter/material.dart';

import 'package:prenotazioni/model/prenotazione.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({Key? key, required this.current}) : super(key: key);

  final Prenotazione current;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {

  @override
  Widget build(BuildContext context) {
    String statusText = widget.current.effettuata!
        ? 'Effettuata'
        : widget.current.attiva!
          ? 'Attiva'
          : 'Annullata';

    const Map<String, Color> statusColor = {
      'Attiva': Colors.blue,
      'Effettuata': Colors.green,
      'Annullata': Colors.red
    };

    Widget appointmentStatus = Text(
      statusText,
      textScaleFactor: 0.9,
      style: TextStyle(color: statusColor[statusText]),
    );

    final Widget statusChangeMenu = PopupMenuButton(
        offset: const Offset(-5.0, 5.0),
        icon: const Icon(Icons.more_vert),
        elevation: 5.0,
        itemBuilder: (context) => <PopupMenuEntry<String>>[

          /* Opzione disponibile solo per gli utenti */
          PopupMenuItem<String>(
              value: 'Effettua',
              child: Row(
                children: const [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10.0),
                  Text('Effettua')
                ],
              ),
              onTap: () => setState(() {
                widget.current.setAppointed();
              }),
            ),
          /* Opzione disponibile per utenti ed amministratori */
          PopupMenuItem<String>(
              value: 'Annulla',
              child: Row(
                  children: const [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 10.0),
                    Text('Annulla')
                  ]
              ),
              onTap: () => setState(() {
                widget.current.setCancelled();
              }),
            )
        ]
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridTile(
          footer: Align(
            alignment: Alignment.bottomRight,
              child: appointmentStatus
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.current.docente),
                  Visibility(
                    visible: widget.current.attiva != false,
                    child: statusChangeMenu,
                  )
                ],
              ),
              const SizedBox(height: 20.0),
              Text(
                widget.current.corso
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Text(widget.current.fasciaOraria),
                  const SizedBox(width: 10.0),
                  Text(
                    widget.current.data,
                    textScaleFactor: 0.75,
                    style: TextStyle(color: Colors.grey[500]),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppointmentsList extends StatelessWidget {
  const AppointmentsList(this.appointments, {Key? key}) : super(key: key);

  final List<Prenotazione> appointments;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'Nessuna prenotazione trovata.\n' 'Perchè non crearne una?',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return AppointmentCard(
          current: appointments[index],
        );
      },
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500.0,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0
      ),
    );
  }
}
