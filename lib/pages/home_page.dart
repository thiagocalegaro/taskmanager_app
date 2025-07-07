import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarefa.dart';
import 'package:task_manager/pages/edit_task_page.dart';
import '../services/tarefa_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Tarefa> _tarefas = [];
  List<Tarefa> _tarefasFiltradas = [];
  final _tarefaService = TarefaService();
  bool _isLoading = true;

  Set<String> _categoriasFiltradas = {};
  DateTimeRange? _intervaloDataFiltrado;
  bool? _filtroConcluido;
  final List<String> _todasAsCategorias = [
    'Pessoal', 'Estudos', 'Trabalho', 'Viagem', 'Lazer', 'Rotina'
  ];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    if (mounted && _tarefas.isEmpty) {
      setState(() => _isLoading = true);
    }
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id');
    if (!mounted) return;

    if (usuarioId != null) {
      final tarefasDoBanco = await _tarefaService.getTarefasByUserId(usuarioId);
      if (mounted) {
        setState(() {
          _tarefas = tarefasDoBanco;
          _isLoading = false;
          _aplicarFiltros();
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _aplicarFiltros() {
    List<Tarefa> tarefasTemp = List.from(_tarefas);
    if (_categoriasFiltradas.isNotEmpty) {
      tarefasTemp = tarefasTemp.where((t) => _categoriasFiltradas.contains(t.categoria)).toList();
    }
    if (_intervaloDataFiltrado != null) {
      tarefasTemp = tarefasTemp.where((t) {
        final dataTarefa = DateTime(t.data.year, t.data.month, t.data.day);
        final dataInicio = DateTime(_intervaloDataFiltrado!.start.year, _intervaloDataFiltrado!.start.month, _intervaloDataFiltrado!.start.day);
        final dataFim = DateTime(_intervaloDataFiltrado!.end.year, _intervaloDataFiltrado!.end.month, _intervaloDataFiltrado!.end.day);
        return !dataTarefa.isBefore(dataInicio) && !dataTarefa.isAfter(dataFim);
      }).toList();
    }
    if (_filtroConcluido != null) {
      tarefasTemp = tarefasTemp.where((t) => t.isCompleted == _filtroConcluido).toList();
    }
    if (mounted) {
      setState(() {
        _tarefasFiltradas = tarefasTemp;
        _tarefasFiltradas.sort((a, b) => a.data.compareTo(b.data));
      });
    }
  }

  void _limparFiltrosAtivos() {
    setState(() {
      _categoriasFiltradas.clear();
      _intervaloDataFiltrado = null;
      _filtroConcluido = null;
      _aplicarFiltros();
    });
  }

  void _deleteTarefa(int index) async {
    final tarefaParaDeletar = _tarefasFiltradas[index];
    if (tarefaParaDeletar.id == null) return;

    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
          content: const Text('Você tem certeza que deseja apagar esta tarefa permanentemente?', style: TextStyle(fontSize: 12)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _tarefaService.deleteTarefa(tarefaParaDeletar.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa excluída!'), backgroundColor: Colors.red),
        );
        carregarTarefas();
      }
    }
  }

  void _toggleTarefaCompleta(Tarefa tarefa, bool? novoStatus) async {
    if (novoStatus == null || !mounted) return;
    setState(() => tarefa.isCompleted = novoStatus);
    final tarefaAtualizada = tarefa.copyWith(isCompleted: novoStatus);
    await _tarefaService.updateTarefa(tarefaAtualizada);
  }

  void _editTarefa(Tarefa tarefa) async {
    final foiAtualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditTaskPage(tarefa: tarefa)),
    );
    if (foiAtualizado == true && mounted) {
      carregarTarefas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFilterActive = _categoriasFiltradas.isNotEmpty || _intervaloDataFiltrado != null || _filtroConcluido != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suas Tarefas"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo-cru.png'),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt_outlined, size: 28),
                onPressed: _mostrarDialogoFiltro,
              ),
              if (isFilterActive)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    height: 8, width: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFilterActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: ActionChip(
                avatar: const Icon(Icons.clear, size: 16),
                label: const Text('Limpar Filtros'),
                onPressed: _limparFiltrosAtivos,
              ),
            ),
          Expanded(
            child: _tarefas.isEmpty
                ? const Center(
              child: Text(
                'Você ainda não tem tarefas.\nAdicione uma no botão de + no rodapé!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : _tarefasFiltradas.isEmpty
                ? const Center(
              child: Text(
                'Nenhuma tarefa encontrada com os filtros atuais.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: _tarefasFiltradas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefasFiltradas[index];
                return _buildTaskItem(tarefa, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Tarefa tarefa, int index) {
    final cardBackgroundColor = tarefa.isExpanded ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6);
    final textColor = Colors.black87;
    final subTextColor = textColor.withOpacity(0.7);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      tarefa.nome.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Data visível
                Text(
                  DateFormat('dd/MM', 'pt_BR').format(tarefa.data),
                  style: TextStyle(color: subTextColor, fontSize: 13),
                ),
                IconButton(
                  icon: Icon(tarefa.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black54),
                  onPressed: () => setState(() => tarefa.isExpanded = !tarefa.isExpanded),
                ),
                Checkbox(
                  value: tarefa.isCompleted,
                  onChanged: (novoStatus) => _toggleTarefaCompleta(tarefa, novoStatus),
                  activeColor: Colors.black
                ),
              ],
            ),
            if (tarefa.isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoria: ${tarefa.categoria}', style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 8.0),
                    if (tarefa.descricao != null && tarefa.descricao!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('Descrição: ${tarefa.descricao}', style: TextStyle(color: Colors.grey[700], height: 1.4)),
                      ),
                    Text('Data: ${DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(tarefa.data)}', style: TextStyle(color: Colors.grey[700])),
                    // Botões de Ação na parte expandida
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Editar Tarefa',
                          icon: const Icon(Icons.edit_outlined, color: Colors.black54, size: 22),
                          onPressed: () => _editTarefa(tarefa),
                        ),
                        IconButton(
                          tooltip: 'Excluir Tarefa',
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
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

  void _mostrarDialogoFiltro() {
    Set<String> tempCategorias = Set.from(_categoriasFiltradas);
    DateTimeRange? tempDataRange = _intervaloDataFiltrado;
    bool? tempStatus = _filtroConcluido;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Filtrar Tarefas', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categorias', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _todasAsCategorias.map((categoria) {
                        return FilterChip(
                          label: Text(categoria),
                          selected: tempCategorias.contains(categoria),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                tempCategorias.add(categoria);
                              } else {
                                tempCategorias.remove(categoria);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 24),
                    const Text('Data', style: TextStyle(fontWeight: FontWeight.w600)),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        tempDataRange == null
                            ? 'Selecionar intervalo'
                            : '${DateFormat('dd/MM/yy', 'pt_BR').format(tempDataRange!.start)} - ${DateFormat('dd/MM/yy', 'pt_BR').format(tempDataRange!.end)}',
                      ),
                      trailing: const Icon(Icons.calendar_today_outlined),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          initialDateRange: tempDataRange,
                          locale: const Locale('pt', 'BR'),
                        );
                        if (picked != null) {
                          setDialogState(() => tempDataRange = picked);
                        }
                      },
                    ),
                    const Divider(height: 24),
                    const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),

                    Wrap(
                      spacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('Todas'),
                          selected: tempStatus == null,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => tempStatus = null);
                          },
                        ),
                        FilterChip(
                          label: const Text('Pendentes'),
                          selected: tempStatus == false,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => tempStatus = false);
                          },
                        ),
                        FilterChip(
                          label: const Text('Concluídas'),
                          selected: tempStatus == true,
                          onSelected: (selected) {
                            if (selected) setDialogState(() => tempStatus = true);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _categoriasFiltradas = tempCategorias;
                      _intervaloDataFiltrado = tempDataRange;
                      _filtroConcluido = tempStatus;
                      _aplicarFiltros();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}