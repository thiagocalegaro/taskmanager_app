import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/dao/tarefa_dao.dart';
import 'package:task_manager/dao/usuario_dao.dart';
import 'package:task_manager/pages/login_page.dart';
import 'package:task_manager/services/usuario_service.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onDataChanged; // Callback para atualizar a HomePage
  const ProfilePage({this.onDataChanged, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _userDao = UserDao();
  final _tarefaDao = TarefaDao();
  final _authService = UsuarioService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  String _userName = 'Usuário Ordo';
  int _tarefasConcluidas = 0;
  int _tarefasPendentes = 0;
  File? _imageFile;

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

    final usuario = await _userDao.getUserById(usuarioId);
    final todasAsTarefas = await _tarefaDao.getTarefasByUserId(usuarioId);
    final concluidas = todasAsTarefas.where((t) => t.isCompleted).length;
    final pendentes = todasAsTarefas.length - concluidas;

    File? tempImageFile;
    if (usuario?.imagePath != null && usuario!.imagePath!.isNotEmpty) {
      tempImageFile = File(usuario.imagePath!);
    }

    if (mounted) {
      setState(() {
        _userName = usuario?.username ?? 'Usuário Ordo';
        _tarefasConcluidas = concluidas;
        _tarefasPendentes = pendentes;
        _imageFile = tempImageFile;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id');
    if (usuarioId == null) return;

    final currentUser = await _userDao.getUserById(usuarioId);
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(username: newName);
    await _userDao.updateUser(updatedUser);

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
          title: const Text('Alterar Nome', textAlign: TextAlign.center,),
          content: TextField(controller: nameController, autofocus: true, decoration: const InputDecoration(hintText: 'Digite seu nome')),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(nameController.text), child: const Text('Salvar')),
          ],
        ));
    if (newName != null && newName.isNotEmpty) {
      await _saveUserName(newName);
    }
  }

  Future<void> _showClearDataDialog() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar Tarefas Concluídas?'),
        content: const Text('Esta ação é permanente. Deseja continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Apagar')),
        ],
      ),
    );

    if (confirmacao == true) {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('user_id');
      if (usuarioId != null) {
        await _tarefaDao.deleteCompletedTasks(usuarioId);
        carregarDados(); // Recarrega os dados do perfil
        widget.onDataChanged?.call(); // Avisa a HomePage para recarregar
      }
    }
  }

  Future<void> _logout() async {
    final confirmarLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Você tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Sair')),
        ],
      ),
    );
    if (confirmarLogout == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (Route<dynamic> route) => false);
      }
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Galeria'), onTap: () { _getImage(ImageSource.gallery); Navigator.of(context).pop(); }),
              ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Câmera'), onTap: () { _getImage(ImageSource.camera); Navigator.of(context).pop(); }),
              if (_imageFile != null) ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red), title: const Text('Remover Foto', style: TextStyle(color: Colors.red)), onTap: _removerFoto)
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 50, maxWidth: 500);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(pickedFile.path);
    final localImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

    await _salvarCaminhoDaImagem(localImage.path);

    setState(() {
      _imageFile = localImage;
    });
  }

  Future<void> _removerFoto() async {
    Navigator.of(context).pop(); // Fecha o BottomSheet
    if (_imageFile != null && await _imageFile!.exists()) {
      await _imageFile!.delete();
    }
    await _salvarCaminhoDaImagem(null); // Salva null no banco
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _salvarCaminhoDaImagem(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('user_id');
    if (usuarioId == null) return;
    final currentUser = await _userDao.getUserById(usuarioId);
    if (currentUser == null) return;
    final updatedUser = currentUser.copyWith(imagePath: path);
    await _userDao.updateUser(updatedUser);
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
          GestureDetector(
            onTap: () => _showPickerOptions(context),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                    child: _imageFile == null
                        ? Text(
                      _userName.isNotEmpty ? _userName.substring(0, 2).toUpperCase() : 'N/A',
                      style: const TextStyle(fontSize: 40, color: Colors.black54),
                    )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Alterar foto",
                    style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Opacity(
                opacity: 0,
                child: IconButton(icon: Icon(Icons.edit_outlined), onPressed: null),
              ),
              Expanded(
                child: Text(
                  _userName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                onPressed: _showEditNameDialog,
              ),
            ],
          ),
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