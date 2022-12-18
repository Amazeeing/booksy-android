class Corso {

  Corso({required this.nome, required this.attivo});

  String nome;
  bool attivo = true;

  Corso.fromJson(Map<String, dynamic> json)
      : nome = json['nome'],
        attivo = json['attivo'];

  Map<String, dynamic> toJson() => {
    'nome' : nome,
    'attivo': attivo,
  };
}