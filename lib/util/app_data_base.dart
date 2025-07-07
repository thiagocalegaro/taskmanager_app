import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDataBase {
  static final AppDataBase _instance = AppDataBase._internal();
  static Database? _database;

  factory AppDataBase() => _instance;

  AppDataBase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    const dbVersion = 1;

    try {
      final path = join(await getDatabasesPath(), 'task_manager_app_database.db');
      return openDatabase(
        path,
        version: dbVersion,
        onCreate: (db, version) async {
          //tabela tarefas
          await db.execute('''
            CREATE TABLE tarefas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              categoria TEXT NOT NULL,
              descricao TEXT,
              data TEXT NOT NULL,
              isCompleted INTEGER NOT NULL DEFAULT 0,
              usuario_id INTEGER,
              FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
            )
          ''');

          //tabela usuarios
          await db.execute('''
            CREATE TABLE usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              password TEXT NOT NULL,
              image_path TEXT,
            )
          ''');
        },
      );
    } catch (e, stackTrace) {
      print("ERRO CAPTURADO DENTRO DO _initDatabase:");
      print("ERRO: $e");
      print("STACK TRACE: $stackTrace");
      rethrow;
    }
  }
}