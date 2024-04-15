class Despesa {
  final String nome;
  final String valor;
  final String data;

  Despesa({required this.nome, required this.valor, required this.data});

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'valor': valor,
      'data': data
    };
  }
}