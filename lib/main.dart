// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importe esta linha
import 'package:intl/date_symbol_data_local.dart';
import 'package:task_manager/pages/login_page.dart';
import 'package:task_manager/pages/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/util/app_data_base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await AppDataBase().database; // Inicializa o banco de dados

  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');

  // Decide qual tela mostrar com base na sessão
  final Widget telaInicial = userId == null ? const LoginPage() : const MainScreen();

  runApp(MyApp(telaInicial: telaInicial));
}

class MyApp extends StatelessWidget {
  final Widget telaInicial;
  const MyApp({required this.telaInicial, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordo',
      debugShowCheckedModeBanner: false,

      // ✅ ADICIONADO: Configuração de localização para corrigir o erro
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Define o Português do Brasil como idioma suportado
      ],
      locale: const Locale('pt', 'BR'), // Define o idioma padrão do app

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: telaInicial, // Usa a tela inicial que definimos no main()
    );
  }
}