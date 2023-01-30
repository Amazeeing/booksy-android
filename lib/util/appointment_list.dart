import 'package:flutter/material.dart';

import 'package:prenotazioni/model/prenotazione.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard(this.current, this.isAdmin, {Key? key})
      : super(key: key);

  final Prenotazione current;
  final bool isAdmin;

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  List<PopupMenuItem<String>> _getPopupMenuItems() {
    return <PopupMenuItem<String>>[
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
                try {
                  widget.current.setAppointed();
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                            icon: Icon(Icons.warning_amber),
                            title: Text('Errore'),
                            content: Text(
                                'Si e\' verificato un errore durante l\'effettuazione della prenotazione'
                            ),
                      )
                  );
                }
              })),
      PopupMenuItem<String>(
          value: 'Annulla',
          child: Row(children: const [
            Icon(Icons.close, color: Colors.red),
            SizedBox(width: 10.0),
            Text('Annulla')
          ]),
          onTap: () => setState(() {
                try {
                  widget.current.setCancelled();
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                            icon: Icon(Icons.warning_amber),
                            title: Text('Errore'),
                            content: Text(
                                'Si e\' verificato un errore durante la cancellazione della prenotazione'),
                          ));
                }
              })
      )
    ];
  }

  Widget _getStatusChangeMenu() {
    if (widget.isAdmin) {
      return IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: () => setState(() {
            widget.current.setCancelled();
          })
      );
    }

    return PopupMenuButton(
        offset: const Offset(-5.0, 5.0),
        icon: const Icon(Icons.more_vert),
        elevation: 5.0,
        itemBuilder: (context) => _getPopupMenuItems());
  }

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

    final Widget statusChangeMenu = _getStatusChangeMenu();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridTile(
          footer:
              Align(alignment: Alignment.bottomRight, child: appointmentStatus),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.current.corso, textScaleFactor: 1.25),
                  Visibility(
                    visible: statusText == 'Attiva',
                    child: statusChangeMenu,
                  )
                ],
              ),
              const SizedBox(height: 10.0),
              Text(widget.current.docente),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.current.fasciaOraria),
                  const SizedBox(width: 10.0),
                  Text(widget.current.data,
                      textScaleFactor: 0.75,
                      style: TextStyle(color: Colors.grey[500]))
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
  const AppointmentsList(this.appointments, this.isAdmin, {Key? key})
      : super(key: key);

  final List<Prenotazione> appointments;
  final bool isAdmin;

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
        return AppointmentCard(appointments[index], isAdmin);
      },
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 600.0,
          childAspectRatio: 3.5 / 2.25,
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 20.0
      ),
    );
  }
}
