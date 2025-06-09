import 'package:flutter/material.dart';
import 'package:task_manager/models/tarefa.dart'; // Para o tipo Tarefa
import 'package:task_manager/pages/add_tasks_page.dart';
import 'package:task_manager/pages/home_page.dart';
import 'package:task_manager/pages/settings_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndexInWidgets = 0; // Índice para a lista _widgetOptions (0 para Home, 1 para Settings)

  // Chave global para acessar o estado da HomePage e chamar o método de adicionar tarefa
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(key: _homePageKey), // Passa a chave para a HomePage
      const SettingsPage(),
    ];
  }

  Future<void> _navegarParaAdicionarTarefa() async {
    final novaTarefa = await Navigator.push<Tarefa>(
      context,
      MaterialPageRoute(builder: (_) => const AddTasksPage()),
    );

    if (novaTarefa != null && mounted) {
      // Chama o método na HomePage para adicionar a nova tarefa
      _homePageKey.currentState?.adicionarTarefaPelaNavegacao(novaTarefa);
    }
  }

  void _onItemTapped(int bnbIndex) { // bnbIndex é o índice do item da BottomNavigationBar
    if (bnbIndex == 1) { // Índice 1 é o "Adicionar Tarefa"
      _navegarParaAdicionarTarefa();
      // Não mudamos _selectedIndexInWidgets aqui, pois "Adicionar" é uma ação modal
      // e não uma página persistente no IndexedStack que queremos manter selecionada.
      // A aba selecionada visualmente na BottomNavigationBar não mudará para "Adicionar".
    } else {
      setState(() {
        // Mapeia o bnbIndex para o _selectedIndexInWidgets
        // Home (bnbIndex 0) -> _selectedIndexInWidgets = 0
        // Configurações (bnbIndex 2) -> _selectedIndexInWidgets = 1
        _selectedIndexInWidgets = (bnbIndex == 2) ? 1 : 0;
      });
    }
  }

  int get _currentBnbIndex {
    // Mapeia o índice da página atual (_selectedIndexInWidgets) de volta para o
    // índice correspondente na BottomNavigationBar para destacar o item correto.
    if (_selectedIndexInWidgets == 0) return 0; // HomePage -> BNB item 0 (Home)
    if (_selectedIndexInWidgets == 1) return 2; // SettingsPage -> BNB item 2 (Ajustes)
    return 0; // Padrão
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O AppBar agora está dentro de cada página (HomePage, SettingsPage)
      body: IndexedStack( // IndexedStack preserva o estado das páginas filhas
        index: _selectedIndexInWidgets,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Ícone quando ativo
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _currentBnbIndex, // Define qual item está selecionado visualmente
        selectedItemColor: Theme.of(context).primaryColorDark, // Cor do ícone e label selecionado
        unselectedItemColor: Colors.grey[600], // Cor dos itens não selecionados
        showUnselectedLabels: true, // Mostra os labels mesmo não selecionados
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Garante que todos os itens apareçam (bom para 3-5 itens)
      ),
    );
  }
}