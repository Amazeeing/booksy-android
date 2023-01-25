class SlotDisponibile {
  SlotDisponibile({required this.docente, required this.data, required this.fasciaOraria});

  final String docente;
  final String data;
  final String fasciaOraria;

  @override
  String toString() {
    return 'SlotDisponibile{data: $data, fasciaOraria: $fasciaOraria}';
  }
}