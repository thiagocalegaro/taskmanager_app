import 'package:task_manager/models/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dao/usuario_dao.dart';

class UsuarioService{
  final UserDao _userDao = UserDao();

  Future<int?> register(Usuario user) async {
      return await _userDao.insertUser(user);
  }

  Future<Usuario?> login(String email, String senha) async {
    final user = await _userDao.getUser(email, senha);

    if (user != null && user.id != null) {

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_id', user.id!);
      return user;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  Future<Usuario?> updateUser(Usuario user) async {
    await _userDao.updateUser(user);
    return user;
  }

  Future<Usuario?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId != null) {
      return await _userDao.getUserById(userId);
    }
    return null;
  }
  Future<Usuario?> getUserById(int id) async {
    return await _userDao.getUserById(id);
  }
}