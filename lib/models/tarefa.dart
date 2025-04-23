class Tarefa {
  final String nome;
  final String categoria;
  final String? descricao;
  final DateTime data;

  Tarefa ({
    required this.nome,
    required this.categoria,
    this.descricao,
    required this.data,
  });

  @override
  String toString() {
    return 'Tarefa{nome: $nome, categoria: $categoria, descricao: $descricao, data: $data}';
  }
}


