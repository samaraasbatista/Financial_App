class Expense {
  int? id;
  String nome;
  double valor;
  String data;

  Expense({
    this.id,
    required this.nome,
    required this.valor,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'data': data,
    };
  }
}