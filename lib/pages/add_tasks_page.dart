import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/models/tarefa.dart';
import 'package:task_manager/services/tarefa_service.dart';
import 'package:task_manager/services/usuario_service.dart';

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key});

  @override
  State<AddTasksPage> createState() => _AddTasksPageState();
}

class _AddTasksPageState extends State<AddTasksPage> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UsuarioService();
  final _tarefaService = TarefaService();
  bool _isLoading = false;

  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final dataController = TextEditingController();

  DateTime? _dataHoraSelecionada;

  final List<String> categorias = [
    'Viagem', 'Trabalho', 'Lazer', 'Rotina', 'Pessoal', 'Estudos',
  ];
  String? categoriaSelecionada;

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
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada == null) return;

    final horaInicial = TimeOfDay.fromDateTime(_dataHoraSelecionada ?? dataInicial);
    final horaSelecionada = await showTimePicker(
      context: context,
      initialTime: horaInicial,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horaSelecionada != null) {
      setState(() {
        _dataHoraSelecionada = DateTime(
          dataSelecionada.year, dataSelecionada.month, dataSelecionada.day,
          horaSelecionada.hour, horaSelecionada.minute,
        );
        dataController.text = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(_dataHoraSelecionada!);
      });
    }
  }

  Future<void> _salvarTarefa() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('user_id');

      if (usuarioId == null) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Sessão de usuário não encontrada!'), backgroundColor: Colors.red));
          setState(() => _isLoading = false);
        }
        return;
      }

      final usuarioLogado = await _userService.getUserById(usuarioId);

      if (usuarioLogado == null) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Usuário não encontrado no banco!'), backgroundColor: Colors.red));
          setState(() => _isLoading = false);
        }
        return;
      }

      final novaTarefa = Tarefa(
        nome: nomeController.text.trim(),
        categoria: categoriaSelecionada!,
        data: _dataHoraSelecionada!,
        descricao: descricaoController.text.trim(),
        usuario: usuarioLogado,
      );

      final idDaTarefaCriada = await _tarefaService.insertTarefa(novaTarefa);

      if (mounted) {
        if (idDaTarefaCriada != null) {

          final tarefaSalva = novaTarefa.copyWith(id: idDaTarefaCriada);
          Navigator.pop(context, true);

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao salvar a tarefa.'), backgroundColor: Colors.red),
          );
        }

        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Tarefa'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nome da Tarefa', hintText: 'Ex: Ir ao supermercado'),
                validator: (value) => (value == null || value.isEmpty) ? 'O nome da tarefa é obrigatório.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Descrição (Opcional)', alignLabelWithHint: true),
                maxLines: 4,
                textInputAction: TextInputAction.newline,
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
                validator: (value) => (_dataHoraSelecionada == null) ? 'A data e hora são obrigatórias.' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarTarefa,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Text('Salvar Tarefa', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}