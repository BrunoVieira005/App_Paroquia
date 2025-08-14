import 'package:flutter/material.dart';
import 'package:projeto_extensao/pages/Calendarios/calendario_eventos.dart';
import 'package:projeto_extensao/pages/Login/Login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:projeto_extensao/Horarios.dart';
import 'package:projeto_extensao/sobre.dart';
import 'package:projeto_extensao/oracoes.dart';
import 'package:projeto_extensao/pages/Calendarios/CalendarioLitur.dart';
import 'package:projeto_extensao/contatos.dart'; // nova página importada
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('pt_BR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Corrigir: Passando a função como um parâmetro diretamente
  final List<Widget> _pages = [];

  // Função de navegação
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Passando a função de navegação para a página inicial
    _pages.addAll([
      HomePageContent(onNavigate: _onItemTapped),
      HorariosScreen(),
      OracoesPage(),
      LoginScreen(),
      SobrePage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.sort, color: Colors.brown),
                iconSize: 45,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFC29A51)),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.contacts, size: 30),
              iconColor: Colors.brown,
              title: Text('Contatos', style: TextStyle(fontSize: 23)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContatosPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFFC29A51),
        unselectedItemColor: Color(0xFFC29A51),
        iconSize: 45,
        selectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            label: 'Horários',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            label: 'Orações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            label: 'Info',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.church_outlined),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final Function(int) onNavigate; // Função de navegação

  const HomePageContent({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/fundo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100),
            Text(
              'PARÓQUIA SANTA MONICA',
              style: TextStyle(
                fontFamily: 'Castellar',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC29A51),
              ),
            ),
            SizedBox(height: 20),
            _buildCard(
              title: 'Calendário Litúrgico',
              description:
                  'Acompanhe o calendário litúrgico e suas celebrações.',
              icon: Icons.calendar_today,
              onTap: () {
                // Navegar para a página de calendário litúrgico
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarioPage()),
                ); // Deixe a navegação como estava
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(Icons.access_time, 'Horários', () {
                  onNavigate(1); // Navegar para Horários
                }),
                _buildIconButton(Icons.self_improvement, 'Orações', () {
                  onNavigate(2); // Navegar para Orações
                }),
                _buildIconButton(Icons.church, 'Sobre', () {
                  onNavigate(4); // Navegar para Sobre
                }),
              ],
            ),
            SizedBox(height: 10),
            _buildCard(
              title: 'Eventos da Paróquia',
              description: 'Fique informado sobre as celebrações e atividades.',
              icon: Icons.event,
              onTap: () {
                // Navegar para eventos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarioEventosPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: Color(0xFFC29A15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF7B5101), size: 40),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          subtitle: Text(description, style: TextStyle(color: Colors.white70)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, size: 40, color: Colors.brown),
            onPressed: onTap,
          ),
          Text(label, style: TextStyle(color: Colors.brown)),
        ],
      ),
    );
  }
}
