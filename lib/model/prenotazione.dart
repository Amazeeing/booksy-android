import 'package:http/http.dart' as http;

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

  Future<bool> _setAppointedDB() async {
      final response = await http.post(
          Uri.parse('http://localhost:8080/progetto_TWeb_war_exploded/prenotazioni?action=impostaPrenotazioneEffettuata' +
                    '&emailDocente=$docente&data=$data&fasciaOraria=$fasciaOraria'));

      return response.statusCode == 200;
  }

  void setAppointed() {
    effettuata = true;

    /* Richiesta a servlet di impostare la prenotazione come effettuata anche sul model (database) */
    _setAppointedDB();
  }

  Future<bool> _setCancelledDB() async {
    final response = await http.post(
        Uri.parse('http://localhost:8080/progetto_TWeb_war_exploded/prenotazioni?action=rimuoviPrenotazioni' +
            '&idCorso=$corso&emailDocente=$docente&data=$data&fasciaOraria=$fasciaOraria'));

    return response.statusCode == 200;
  }

  void setCancelled() {
    attiva = false;

    /* Richiesta a servlet di impostare la prenotazione come cancellata anche sul model (database) */
    _setCancelledDB();
  }
}
