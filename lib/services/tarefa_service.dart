import '../dao/tarefa_dao.dart';
import '../models/tarefa.dart';

class TarefaService{
  final tarefaDao = TarefaDao();

  Future<int> updateTarefa(Tarefa tarefa) async {
    return await tarefaDao.updateTarefa(tarefa);
  }
  Future<int> deleteTarefa(int id) async {
    return await tarefaDao.deleteTarefa(id);
  }
  Future<int?> insertTarefa(Tarefa tarefa) async {
    return await tarefaDao.insertTarefa(tarefa);
  }
  Future<List<Tarefa>> getTarefasByUserId(int usuarioId) async {
    return await tarefaDao.getTarefasByUserId(usuarioId);
  }
  Future<int> deleteCompletedTasks(int usuarioId) async {
    return await tarefaDao.deleteCompletedTasks(usuarioId);
  }


}