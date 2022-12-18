class Docente {
  Docente({required this.email, required this.password, required this.nome, required this.cognome});

  final String email;
  final String password;
  final String nome;
  final String cognome;

  bool attivo = true;

  Docente.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        password = json['password'],
        nome = json['nome'],
        cognome = json['cognome'];

  Map<String, dynamic> toJson() => {
    'email' : email,
    'password' : password,
    'nome' : nome,
    'cognome' : cognome,
  };
}