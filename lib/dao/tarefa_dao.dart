import 'package:sqflite/sqflite.dart';
import 'package:task_manager/dao/usuario_dao.dart';
import 'package:task_manager/models/usuario.dart';
import '../models/tarefa.dart';
import '../util/app_data_base.dart'; // Corrigido para o seu nome de arquivo

class TarefaDao {
  static const String table = 'tarefas';

  /// Atualiza uma tarefa existente. Retorna o número de linhas afetadas.
  Future<int> updateTarefa(Tarefa tarefa) async {
    try {
      final db = await AppDataBase().database;
      return await db.update(
        table,
        tarefa.toMap(),
        where: 'id = ?',
        whereArgs: [tarefa.id],
      );
    } catch (e) {
      print('ERRO AO ATUALIZAR TAREFA: $e');
      return 0;
    }
  }

  /// Deleta uma tarefa pelo seu ID. Retorna o número de linhas afetadas.
  Future<int> deleteTarefa(int id) async {
    try {
      final db = await AppDataBase().database;
      return await db.delete(
        table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('ERRO AO DELETAR TAREFA: $e');
      return 0;
    }
  }

  Future<int?> insertTarefa(Tarefa tarefa) async {
    try {
      final db = await AppDataBase().database;
      // O método tarefa.toMap() já extrai o usuario.id corretamente
      return await db.insert(table, tarefa.toMap());
    } catch (e) {
      print('ERRO AO INSERIR TAREFA: $e');
      return null;
    }
  }

  Future<int> deleteCompletedTasks(int usuarioId) async {
    try {
      final db = await AppDataBase().database;
      return await db.delete(
        table,
        where: 'usuario_id = ? AND isCompleted = ?',
        whereArgs: [usuarioId, 1],
      );
    } catch (e) {
      print('ERRO AO DELETAR TAREFAS CONCLUÍDAS: $e');
      return 0;
    }
  }

  Future<List<Tarefa>> getTarefasByUserId(int usuarioId) async {
    try {
      final db = await AppDataBase().database;
      final userDao = UserDao();
      final usuario = await userDao.getUserById(usuarioId); // Você precisará deste método no UserDao
      if (usuario == null) {
        // Se o usuário não for encontrado, não há tarefas para retornar
        return [];
      }

      // 2. Busca todas as tarefas que pertencem a esse usuário
      final result = await db.query(
        table,
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
      );

      // 3. "Monta" a lista de objetos Tarefa, injetando o objeto Usuario em cada uma
      List<Tarefa> tarefas = result.map((tarefaMap) {
        return Tarefa(
          id: tarefaMap['id'] as int?,
          nome: tarefaMap['nome'] as String,
          categoria: tarefaMap['categoria'] as String,
          descricao: tarefaMap['descricao'] as String?,
          data: DateTime.parse(tarefaMap['data'] as String),
          isCompleted: (tarefaMap['isCompleted'] as int) == 1,
          usuario: usuario, // Injeta o objeto de usuário completo aqui!
        );
      }).toList();

      return tarefas;
    } catch (e) {
      print('ERRO AO BUSCAR TAREFAS POR USUÁRIO: $e');
      return [];
    }
  }
}