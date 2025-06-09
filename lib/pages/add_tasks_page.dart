import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Importar o pacote intl
import 'package:task_manager/models/tarefa.dart';

class AddTasksPage extends StatefulWidget {
  const AddTasksPage({super.key});

  @override
  State<AddTasksPage> createState() => _AddTasksPageState();
}

class _AddTasksPageState extends State<AddTasksPage> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controladores ──────────────────────────────────────────────────────────
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final dataController = TextEditingController(); // Continuará sendo usado para exibir a data/hora formatada

  // ─── Nova variável de estado para data e hora ───────────────────────────────
  DateTime? _dataHoraSelecionada;

  // ─── Dados auxiliares ───────────────────────────────────────────────────────
  final List<String> categorias = [
    'Viagem',
    'Trabalho',
    'Lazer',
    'Rotina',
    'Compromisso',
    'Pessoal', // Adicionando 'Pessoal' que estava na HomePage
    'Estudos', // Adicionando 'Estudos' que estava na HomePage
  ];
  String? categoriaSelecionada;

  @override
  void dispose() {
    nomeController.dispose();
    descricaoController.dispose();
    dataController.dispose();
    super.dispose();
  }

  // ─── Métodos auxiliares para seleção de data e hora ────────────────────────
  Future<void> _selecionarDataHora() async {
    final hoje = DateTime.now();
    final dataInicial = _dataHoraSelecionada ?? hoje;

    // 1. Selecionar Data
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(hoje.year - 5), // Permite selecionar datas até 5 anos no passado
      lastDate: DateTime(hoje.year + 5),  // Permite selecionar datas até 5 anos no futuro
      locale: const Locale('pt', 'BR'),
    );

    if (dataSelecionada != null) {
      // 2. Selecionar Hora (se uma data foi selecionada)
      final horaInicial = TimeOfDay.fromDateTime(_dataHoraSelecionada ?? dataInicial);

      final horaSelecionada = await showTimePicker(
        context: context,
        initialTime: horaInicial,
        // Builder para forçar o formato 24h, opcional mas recomendado para clareza
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );

      if (horaSelecionada != null) {
        // 3. Combinar data e hora e atualizar estado
        setState(() {
          _dataHoraSelecionada = DateTime(
            dataSelecionada.year,
            dataSelecionada.month,
            dataSelecionada.day,
            horaSelecionada.hour,
            horaSelecionada.minute,
          );
          // Formatar para exibição no TextFormField
          dataController.text = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(_dataHoraSelecionada!);
        });
      }
    }
  }

  // ─── Método para salvar a tarefa ────────────────────────────────────────────
  void _salvarTarefa() {
    if (_formKey.currentState!.validate()) {
      // A validação do campo de data/hora agora verifica _dataHoraSelecionada
      if (_dataHoraSelecionada == null) {
        // Esta mensagem é um fallback, o validador do campo deve pegar isso.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione a data e hora.')),
        );
        return;
      }

      final tarefa = Tarefa(
        nome: nomeController.text.trim(),
        categoria: categoriaSelecionada!,
        data: _dataHoraSelecionada!, // Usar a DateTime completa
        descricao: descricaoController.text.trim().isEmpty
            ? null
            : descricaoController.text.trim(),
      );

      Navigator.pop(context, tarefa); // Devolve para HomePage
    }
  }

  // ─── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Tarefa'),
      centerTitle: true), // Singular
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16), // Aumentado padding vertical
        child: Form( // Removido Center, Form já ocupa a largura disponível
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Para o botão ocupar a largura
            children: [
              // NOME ----------------------------------------------------------------
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome da Tarefa',
                  hintText: 'Ex: Ir ao supermercado',
                ),
                // Removido inputFormatter para permitir números e caracteres especiais se necessário.
                // Se quiser restringir, pode adicionar de volta.
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\sÀ-ú.,!?()]')),
                // ],
                validator: (value) =>
                (value == null || value.isEmpty) ? 'O nome da tarefa é obrigatório.' : null,
              ),
              const SizedBox(height: 20),

              // DESCRIÇÃO ------------------------------------------------------------
              TextFormField(
                controller: descricaoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descrição (Opcional)',
                  hintText: 'Ex: Comprar frutas, verduras e produtos de limpeza.',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.newline, // Melhora a experiência com múltiplas linhas
              ),
              const SizedBox(height: 20),

              // CATEGORIA ------------------------------------------------------------
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Categoria',
                ),
                value: categoriaSelecionada,
                hint: const Text('Selecione uma categoria'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => categoriaSelecionada = newValue),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Selecione uma categoria.' : null,
              ),
              const SizedBox(height: 20),

              // DATA E HORA ----------------------------------------------------------
              TextFormField(
                controller: dataController,
                readOnly: true, // Importante: torna o campo não editável manualmente
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data e Hora',
                  hintText: 'Toque para selecionar', // Hint mais claro
                  suffixIcon: Icon(Icons.calendar_today_outlined), // Ícone para indicar interatividade
                ),
                onTap: _selecionarDataHora, // Chama o seletor ao tocar
                validator: (value) {
                  // Valida se _dataHoraSelecionada foi preenchido, não o texto do controller.
                  if (_dataHoraSelecionada == null) {
                    return 'A data e hora são obrigatórias.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32), // Maior espaçamento antes do botão

              // BOTÃO ADICIONAR -------------------------------------------------------
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), // Botão mais alto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordas levemente arredondadas
                  ),
                  // backgroundColor: Theme.of(context).primaryColor, // Exemplo de cor
                  // foregroundColor: Colors.white, // Exemplo de cor do texto
                ),
                onPressed: _salvarTarefa,
                child: const Text('Adicionar Tarefa', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}