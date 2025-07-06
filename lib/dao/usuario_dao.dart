// lib/dao/usuario_dao.dart
import 'package:sqflite/sqflite.dart';
import 'package:task_manager/models/usuario.dart';
import 'package:task_manager/util/app_data_base.dart';

class UserDao {
  static const String table = 'usuarios';

  /// Insere um novo usuário.
  Future<int?> insertUser(Usuario user) async {
    try {
      final db = await AppDataBase().database;
      return await db.insert(
        table,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      print('ERRO AO INSERIR USUÁRIO: $e');
      return null;
    }
  }

  /// Atualiza um usuário existente.
  Future<int> updateUser(Usuario user) async {
    try {
      final db = await AppDataBase().database;
      return await db.update(
        table,
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print('ERRO AO ATUALIZAR USUÁRIO: $e');
      return 0;
    }
  }

  /// Busca um usuário pelo e-mail e senha (para login sem hash).
  Future<Usuario?> getUser(String email, String senha) async {
    try {
      final db = await AppDataBase().database;
      final result = await db.query(
        table,
        where: 'email = ? AND password = ?',
        whereArgs: [email, senha],
        limit: 1,
      );
      return result.isNotEmpty ? Usuario.fromMap(result.first) : null;
    } catch (e) {
      print('ERRO AO BUSCAR USUÁRIO POR EMAIL/SENHA: $e');
      return null;
    }
  }

  /// ✅ MÉTODO ADICIONADO: Busca um usuário pelo seu ID.
  Future<Usuario?> getUserById(int id) async {
    try {
      final db = await AppDataBase().database;
      final result = await db.query(
        table,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return result.isNotEmpty ? Usuario.fromMap(result.first) : null;
    } catch (e) {
      print('ERRO AO BUSCAR USUÁRIO POR ID: $e');
      return null;
    }
  }

  /// Deleta um usuário pelo seu ID.
  Future<int> deleteUser(int id) async {
    try {
      final db = await AppDataBase().database;
      return await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('ERRO AO DELETAR USUÁRIO: $e');
      return 0;
    }
  }
}