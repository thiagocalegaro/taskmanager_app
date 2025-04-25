import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:task_manager/models/tarefa.dart';

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key});

  @override
  State<AddTasksPage> createState() => _AddTasksPageState();
}

class _AddTasksPageState extends State<AddTasksPage> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controladores ──────────────────────────────────────────────────────────
  final nomeController      = TextEditingController();
  final descricaoController = TextEditingController();
  final dataController      = TextEditingController();

  // ─── Dados auxiliares ───────────────────────────────────────────────────────
  final List<String> categorias = [
    'Viagem',
    'Trabalho',
    'Lazer',
    'Rotina',
    'Compromisso',
  ];
  String? categoriaSelecionada;

  @override
  void dispose() {
    // libera memória
    nomeController.dispose();
    descricaoController.dispose();
    dataController.dispose();
    super.dispose();
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Tarefas')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // NOME ----------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nome',
                      hintText: 'Entre com nome válido',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    validator: (value) =>
                    (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // DESCRIÇÃO ------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Descrição',
                      hintText: 'Digite a descrição da tarefa',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // CATEGORIA ------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Categoria',
                    ),
                    value: categoriaSelecionada,
                    hint: const Text('Selecione'),
                    items: categorias
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (newValue) =>
                        setState(() => categoriaSelecionada = newValue),
                    validator: (value) =>
                    (value == null || value.isEmpty) ? 'Selecione uma categoria' : null,
                  ),
                ),
                const SizedBox(height: 16),

                // DATA -----------------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: dataController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Data',
                      hintText: 'AAAA-MM-DD',   // visual
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo obrigatório';

                      // tenta converter pra DateTime; se falhar => formato inválido
                      try {
                        DateTime.parse(value);
                        return null;   // ok
                      } catch (_) {
                        return 'Use o formato AAAA-MM-DD';
                      }
                    },
                  )
                ),
                const SizedBox(height: 24),

                // BOTÃO ADICIONAR -------------------------------------------------------
                SizedBox(
                  height: 50,
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: _salvarTarefa,
                    child: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Métodos auxiliares ─────────────────────────────────────────────────────
  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: DateTime(hoje.year - 5),
      lastDate: DateTime(hoje.year + 5),
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null) {
      dataController.text = selecionada.toIso8601String().split('T').first;
    }
  }

  void _salvarTarefa() {
    if (_formKey.currentState!.validate()) {
      final tarefa = Tarefa(
        nome: nomeController.text.trim(),
        categoria: categoriaSelecionada!,
        data: DateTime.parse(dataController.text),
        descricao: descricaoController.text.trim().isEmpty
            ? null
            : descricaoController.text.trim(),
      );

      Navigator.pop(context, tarefa); // devolve para HomePage
    }
  }
}
