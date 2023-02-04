class Docente {
  Docente({required this.email, required this.nome, required this.cognome});

  final String email;
  final String nome;
  final String cognome;

  bool attivo = true;

  Docente.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        nome = json['nome'],
        cognome = json['cognome'],
        attivo = json['attivo'];

  Map<String, dynamic> toJson() => {
    'email' : email,
    'nome' : nome,
    'cognome' : cognome,
    'attivo': attivo
  };

  @override
  String toString() {
    return 'Docente{email: $email, nome: $nome, cognome: $cognome, attivo: $attivo}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Docente &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          nome == other.nome &&
          cognome == other.cognome &&
          attivo == other.attivo;

  @override
  int get hashCode =>
      email.hashCode ^ nome.hashCode ^ cognome.hashCode ^ attivo.hashCode;
}