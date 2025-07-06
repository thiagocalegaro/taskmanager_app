import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/pages/login_page.dart';
import 'package:task_manager/services/tarefa_service.dart';
import 'package:task_manager/services/usuario_service.dart';

import '../services/usuario_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _tarefaService = TarefaService();
  final _authService = UsuarioService();
  bool _isLoading = true;
  String _userName = 'Usuário Ordo';
  int _tarefasConcluidas = 0;
  int _tarefasPendentes = 0;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id');

    if (usuarioId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final usuario = await _authService.getCurrentUser();
    // Carrega as tarefas para calcular as estatísticas
    final todasAsTarefas = await _tarefaService.getTarefasByUserId(usuarioId);
    final concluidas = todasAsTarefas.where((t) => t.isCompleted).length;
    final pendentes = todasAsTarefas.length - concluidas;

    if (mounted) {
      setState(() {
        _userName = usuario?.username ?? 'Usuário Ordo';
        _tarefasConcluidas = concluidas;
        _tarefasPendentes = pendentes;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id');
    if (usuarioId == null) return;

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(username: newName);
    await _authService.updateUser(updatedUser);

    if (mounted) {
      setState(() {
        _userName = newName;
      });
    }
  }

  Future<void> _showEditNameDialog() async {
    final nameController = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Nome'),
        content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'Digite seu nome')),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(nameController.text), child: const Text('Salvar')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _saveUserName(newName);
    }
  }

  Future<void> _showClearDataDialog() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Tarefas Concluídas?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text('Esta ação é permanente. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('user_id');
      if (usuarioId != null) {
        await _tarefaService.deleteCompletedTasks(usuarioId);
        carregarDados();
      }
    }
  }

  Future<void> _logout() async {
    final confirmarLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        content: const Text('Você tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmarLogout == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil"),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo-cru.png'),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  _userName.isNotEmpty ? _userName.substring(0, 2).toUpperCase() : 'OR',
                  style: const TextStyle(fontSize: 40, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: _showEditNameDialog),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Suas Estatísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn('Concluídas', _tarefasConcluidas.toString()),
                  _buildStatColumn('Pendentes', _tarefasPendentes.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Ações da Conta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.delete_sweep_outlined, color: Colors.red.shade700),
            title: Text('Apagar Tarefas Concluídas', style: TextStyle(color: Colors.red.shade700)),
            onTap: _showClearDataDialog,
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Sair'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Column _buildStatColumn(String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey.shade600)),
      ],
    );
  }
}