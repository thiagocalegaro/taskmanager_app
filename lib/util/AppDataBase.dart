import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDataBase {
  /*static final AppDataBase _instance = AppDataBase._internal();
  static Database? _database;

  factory AppDataBase() => _instance;


  AppDataBase._internal();

  Future<Database> get database async {
    // Simulate a database initialization
    if(_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future <Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'task_manager_app_database.db');
    return openDatabase(
      path,
        version: 1,
      onCreate: (db, version) async {
        // Aqui você pode criar as tabelas necessárias
        await db.execute(
          'CREATE TABLE tarefas(id INTEGER PRIMARY KEY AUTOINCREMENT, nome TEXT, categoria TEXT, descricao TEXT, data TEXT)',
        );
      },
    );
  }*/
}