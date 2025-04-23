import 'package:flutter/material.dart';
import 'package:task_manager/pages/add_tasks_page.dart';
import '../models/tarefa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Tarefa> tarefas = [
    Tarefa(
      nome: 'Estudar Flutter',
      categoria: 'Trabalho',
      descricao: 'Estudar Flutter para o projeto de TCC',
      data: DateTime.now(),
    ),
    Tarefa(
      nome: 'Fazer compras',
      categoria: 'Lazer',
      descricao: 'Comprar frutas e verduras',
      data: DateTime.now(),
    ),
    Tarefa(
      nome: 'Reunião com o cliente',
      categoria: 'Compromisso',
      descricao: 'Reunião para discutir o projeto',
      data: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      floatingActionButton: FloatingActionButton(
        onPressed: _irParaAddTarefa,
        child: const Icon(Icons.add),
      ),
      body: tarefas.isEmpty
          ? const Center(child: Text('Nenhuma tarefa ainda'))
          : ListView.builder(
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          final t = tarefas[index];
          return ListTile(
            title: Text(t.nome),
            subtitle: Text('${t.categoria} • '
                '${t.data.day}/${t.data.month}/${t.data.year}'),
          );
        },
      ),
    );
  }

  Future<void> _irParaAddTarefa() async {
    final novaTarefa = await Navigator.push<Tarefa>(
      context,
      MaterialPageRoute(builder: (_) => const AddTasksPage()),
    );

    if (novaTarefa != null) {
      setState(() => tarefas.add(novaTarefa));
    }
  }
}
