import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
        // Se você não quiser o botão de voltar automático (pois está no IndexedStack)
        // automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Página de Ajustes',
          style: TextStyle(fontSize: 24, color: Colors.black54),
        ),
      ),
    );
  }
}