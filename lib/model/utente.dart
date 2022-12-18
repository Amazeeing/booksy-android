class Utente {
  String username, nome, cognome, ruolo;

  Utente({required this.username,
          required this.nome,
          required this.cognome,
          required this.ruolo});

  Utente.fromJson(Map<String, dynamic> json)
      : username = json['username'],
        nome = json['nome'],
        cognome = json['cognome'],
        ruolo = json['ruolo'];

  Map<String, dynamic> toJson() => {
    'username' : username,
    'nome' : nome,
    'cognome' : cognome,
    'ruolo' : ruolo,
  };

  @override
  String toString() {
    return 'Utente{username: $username,'
            'nome: $nome,'
            'cognome: $cognome,'
            'ruolo: $ruolo}';
  }
}