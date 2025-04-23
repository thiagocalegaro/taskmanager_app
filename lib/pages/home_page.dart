import 'package:flutter/material.dart';
import 'package:task_manager/pages/add_tasks.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home Page'),
          ),
       //listar tarefas
       body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Home Page'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTasksPage(),
                    ),
                  );
                },
                child: const Text('Adicionar Tarefas'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTasksPage(),
                    ),
                  );
                },
                child: const Text('Adicionar Tarefas'),
              ),
            ],
          ),
        )
    );
  }
}