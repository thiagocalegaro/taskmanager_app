// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_manager/pages/add_tasks_page.dart';
import '../models/tarefa.dart';

class HomePage extends StatefulWidget {
  // Adicionar construtor com Key
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  // ... (seu código existente para _tarefas, initState, _sortTarefas, etc.) ...
  // Mantenha a lista _tarefas e os métodos relacionados aqui
  final List<Tarefa> _tarefas = [
    Tarefa(nome: 'LIMPAR QUARTO', categoria: 'Pessoal', data: DateTime.now().add(const Duration(days: 1)), isCompleted: false),
    Tarefa(nome: 'ESTUDAR POO', categoria: 'Estudos', data: DateTime.now().add(const Duration(days: 2, hours: 3)), isCompleted: true),
    Tarefa(nome: 'PASSEAR COM O CACHORRO', categoria: 'Pessoal', data: DateTime.now().add(const Duration(hours: 1)), isCompleted: false),
    Tarefa(nome: 'AGENDAR DENTISTA', categoria: 'Pessoal', descricao: 'Lorem ipsum dolor sit amet...', data: DateTime(2025, 6, 20, 10, 0), isCompleted: false),
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _sortTarefas();
  }

  void _sortTarefas() {
    if (!mounted) return; // Evitar chamar setState se o widget não estiver montado
    setState(() {
      _tarefas.sort((a, b) => a.data.compareTo(b.data));
    });
  }

  // Método público para adicionar tarefa a partir do MainScreen
  void adicionarTarefaPelaNavegacao(Tarefa novaTarefa) {
    if (!mounted) return;
    setState(() {
      _tarefas.add(novaTarefa);
      _sortTarefas();
    });
  }

  // O _irParaAddTarefa original pode ser removido daqui se não for mais usado internamente na HomePage
  // ou pode ser mantido para um possível FAB dentro da HomePage. Por agora, vamos remover
  // para não confundir com a navegação principal.

  void _deleteTarefa(int index) {
    if (!mounted) return;
    setState(() {
      _tarefas.removeAt(index);
    });
  }

  void _editTarefa(Tarefa tarefa) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editar tarefa: ${tarefa.nome}')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( title: const Text("Suas Tarefas"), // AppBar agora é específico da HomePage
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.fact_check_outlined, color: Colors.black54, size: 28),
          onPressed: () {},
        ),
        centerTitle: true, // Centralizar o título
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black54, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O Padding com Filter e o antigo título "Suas Tarefas" e botão de adicionar
          // foi removido daqui, pois o título foi para o AppBar e o add para o BottomNav.
          // Você pode adicionar o botão de filtro de volta ao AppBar se desejar.
          // Ex: actions: [ IconButton(icon: Icon(Icons.filter_list), ...), IconButton(icon: Icon(Icons.menu), ...)]
          Expanded(
            child: _tarefas.isEmpty
                ? const Center(child: Text('Nenhuma tarefa ainda'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefas[index];
                return _buildTaskItem(tarefa, index); // Seu método _buildTaskItem permanece o_buildTaskItem
              },
            ),
          ),
        ],
      ),
    );
  }

  // Seu método _buildTaskItem(...) permanece aqui, sem alterações necessárias nesta etapa
  // para a lógica da BottomNavigationBar.
  Widget _buildTaskItem(Tarefa tarefa, int index) {
    final cardBackgroundColor = tarefa.isExpanded
        ? const Color(0xFFE5E7EB)
        : const Color(0xFFF3F4F6);
    const textColor = Colors.black87;
    final subTextColor = textColor.withOpacity(0.7);

    return Card(
      // ... (código do _buildTaskItem como antes) ...
      color: cardBackgroundColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          tarefa.nome.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (tarefa.isExpanded)
                        Text(
                          '(${tarefa.categoria})',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: subTextColor,
                            fontSize: 13,
                          ),
                        )
                      else
                        Text(
                          DateFormat('dd/MM HH:mm', 'pt_BR').format(tarefa.data),
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: subTextColor,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    tarefa.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    if (!mounted) return;
                    setState(() {
                      _tarefas[index].isExpanded = !_tarefas[index].isExpanded;
                    });
                  },
                ),
                const SizedBox(width: 4),
                Checkbox(
                  value: tarefa.isCompleted,
                  onChanged: (bool? newValue) {
                    if (!mounted) return;
                    setState(() {
                      _tarefas[index].isCompleted = newValue ?? false;
                    });
                  },
                  activeColor: Colors.black87,
                  checkColor: Colors.white,
                  side: const BorderSide(color: Colors.grey, width: 1.5),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            if (tarefa.isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 4.0, right: 4.0, bottom: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (tarefa.descricao != null && tarefa.descricao!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Descrição: ${tarefa.descricao}',
                          style: TextStyle(color: Colors.black54, fontSize: 13.5, height: 1.4),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Data: ${DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(tarefa.data)}',
                        style: TextStyle(color: Colors.black54, fontSize: 13.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Categoria: ${tarefa.categoria}',
                        style: TextStyle(color: Colors.black54, fontSize: 13.5),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.black54, size: 22),
                          onPressed: () => _editTarefa(tarefa),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.black54, size: 22),
                          onPressed: () => _deleteTarefa(index),
                        ),
                      ],
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}