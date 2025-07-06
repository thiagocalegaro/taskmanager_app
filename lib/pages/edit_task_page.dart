import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/services/tarefa_service.dart';
import 'package:task_manager/models/tarefa.dart';

class EditTaskPage extends StatefulWidget {
  final Tarefa tarefa;

  const EditTaskPage({required this.tarefa, super.key});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _tarefaService = TarefaService();
  bool _isLoading = false;

  late final TextEditingController nomeController;
  late final TextEditingController descricaoController;
  late final TextEditingController dataController;
  DateTime? _dataHoraSelecionada;
  String? categoriaSelecionada;

  final List<String> categorias = [
    'Viagem', 'Trabalho', 'Lazer', 'Rotina', 'Compromisso', 'Pessoal', 'Estudos',
  ];

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.tarefa.nome);
    descricaoController = TextEditingController(text: widget.tarefa.descricao);
    _dataHoraSelecionada = widget.tarefa.data;
    dataController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(_dataHoraSelecionada!),
    );
    categoriaSelecionada = widget.tarefa.categoria;
  }

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataHora() async {
    final hoje = DateTime.now();
    final dataInicial = _dataHoraSelecionada ?? hoje;

    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(hoje.year + 5),
      locale: const Locale('pt', 'BR'),
    );
    if (dataSelecionada == null) return;

    final horaInicial = TimeOfDay.fromDateTime(_dataHoraSelecionada ?? dataInicial);
    final horaSelecionada = await showTimePicker(
      context: context,
      initialTime: horaInicial,
    );

    if (horaSelecionada != null && mounted) {
      setState(() {
        _dataHoraSelecionada = DateTime(
          dataSelecionada.year, dataSelecionada.month, dataSelecionada.day,
          horaSelecionada.hour, horaSelecionada.minute,
        );
        dataController.text = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(_dataHoraSelecionada!);
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final tarefaAtualizada = widget.tarefa.copyWith(
        nome: nomeController.text.trim(),
        categoria: categoriaSelecionada!,
        data: _dataHoraSelecionada!,
        descricao: descricaoController.text.trim(),
      );

      await _tarefaService.updateTarefa(tarefaAtualizada);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Tarefa'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nome da Tarefa'),
                validator: (value) => (value == null || value.isEmpty) ? 'O nome é obrigatório.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Descrição (Opcional)'),
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Categoria'),
                value: categoriaSelecionada,
                items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (newValue) => setState(() => categoriaSelecionada = newValue),
                validator: (value) => (value == null) ? 'Selecione uma categoria.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: dataController,
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Data e Hora', suffixIcon: Icon(Icons.calendar_today_outlined)),
                onTap: _selecionarDataHora,
                validator: (value) => (_dataHoraSelecionada == null) ? 'A data é obrigatória.' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarAlteracoes,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Salvar Alterações', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}