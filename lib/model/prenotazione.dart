import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Prenotazione {
  final String utente;
  final String corso;
  final String docente;
  final String data;
  final String fasciaOraria;

  String? dataCancellazione;
  bool? attiva = true;
  bool? effettuata = false;

  Prenotazione({
    required this.utente,
    required this.corso,
    required this.docente,
    required this.data,
    required this.fasciaOraria,
    this.dataCancellazione,
    this.attiva,
    this.effettuata,
  });

  factory Prenotazione.fromJson(Map<String, dynamic> json) {
    return Prenotazione(
        utente: json['utente'],
        corso: json['corso'],
        docente: json['docente'],
        data: json['data'],
        fasciaOraria: json['fasciaOraria'],
        dataCancellazione: json['dataCancellazione'],
        attiva: json['attiva'],
        effettuata: json['effettuata']
    );
  }

  Map<String, dynamic> toJson() => {
        'utente': utente,
        'corso': corso,
        'docente': docente,
        'data': data,
        'fasciaOraria': fasciaOraria,
        'dataCancellazione': dataCancellazione,
        'attiva': attiva,
        'effettuata': effettuata
  };

  Future<void> _setAppointedDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    http.Client client = http.Client();

    /* Imposto la prenotazione come effettuata nel DB */
    await client.post(Uri.http(
        'localhost:8080', '/progetto_TWeb_war_exploded/prenotazioni', {
      'username': username,
      'password': password,
      'action': 'impostaPrenotazioneEffettuata',
      'emailDocente': docente,
      'data': data,
      'fasciaOraria': fasciaOraria
    }));

    client.close();
  }

  void setAppointed() {
    /* Richiesta a servlet di impostare la prenotazione come effettuata anche sul model (database) */
    _setAppointedDB();

    effettuata = true;
  }

  Future<void> _setCancelledDB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    http.Client client = http.Client();

    /* Imposta la prenotazione come cancellata nel DB */
    await client.post(Uri.http(
        'localhost:8080', '/progetto_TWeb_war_exploded/prenotazioni', {
          'username': username,
      'password': password,
      'action': 'rimuoviPrenoazione',
      'idCorso': corso,
      'emailDocente': docente,
      'data': data,
      'fasciaOraria': fasciaOraria
    }));

    client.close();
  }

  void setCancelled() {
    /* Richiesta a servlet di impostare la prenotazione come cancellata anche sul model (database) */
    _setCancelledDB();

    attiva = false;
  }
}
