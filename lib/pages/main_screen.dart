import 'package:flutter/material.dart';
import 'package:task_manager/pages/add_tasks_page.dart';
import 'package:task_manager/pages/home_page.dart';
import 'package:task_manager/pages/profile_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndexInWidgets = 0;
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();
  final GlobalKey<ProfilePageState> _profilePageKey = GlobalKey<ProfilePageState>();

  late final List<Widget> _telas;

  @override
  void initState() {
    super.initState();
    _telas = [
      HomePage(key: _homePageKey),
      ProfilePage(key: _profilePageKey),
    ];
  }

  Future<void> _navegarParaAdicionarTarefa() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTasksPage()),
    );
    if (resultado == true && mounted) {
      _homePageKey.currentState?.carregarTarefas();
    }
  }

  void _onBnbItemTapped(int bnbIndex) {
    if (bnbIndex == 1) { // "Adicionar"
      _navegarParaAdicionarTarefa();
      return;
    }

    final novoIndexWidget = (bnbIndex == 2) ? 1 : 0;

    if (_selectedIndexInWidgets == novoIndexWidget) {
      if (novoIndexWidget == 0) {
        _homePageKey.currentState?.carregarTarefas();
      } else {
        _profilePageKey.currentState?.carregarDados();
      }
    }

    setState(() {
      _selectedIndexInWidgets = novoIndexWidget;
    });

    if (novoIndexWidget == 0) {
      _homePageKey.currentState?.carregarTarefas();
    } else {
      _profilePageKey.currentState?.carregarDados();
    }
  }

  int get _currentBnbIndex {
    if (_selectedIndexInWidgets == 0) return 0; //home
    if (_selectedIndexInWidgets == 1) return 2; //perfil
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndexInWidgets,
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBnbIndex,
        onTap: _onBnbItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Adicionar'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}