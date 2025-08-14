import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HorariosScreen(),
    );
  }
}

class HorariosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo.png'), // Imagem de fundo
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 20),

              // Título estilizado
              const Text(
                'PARÓQUIA SANTA MONICA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC29A51), // Cor dourada
                  fontFamily: 'Castellar', // Fonte estilizada
                ),
              ),
              const SizedBox(height: 20),

              // Seção de horários
              _buildSectionTitle('Horários'),
              _buildCard('Atendimento Padre', [
                'Terça-Feira: 08:00 às 12:00',
                'Sábado: 08:00 às 12:00',
              ]),
              _buildCard('Atendimento Secretaria', [
                'Terça-Feira: 08:00 às 12:00',
                'Quarta a Sexta-Feira: 12:00 às 17:45',
                'Sábado: 08:00 às 12:00',
              ]),
              _buildCard('Missa', ['Sábado: 19:30', 'Domingo: 08:00']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.brown,
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<String> details) {
    return Card(
      color: Color(0xFFC29A51), // Nova cor do fundo
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Texto em branco para contraste
              ),
            ),
            const SizedBox(height: 8.0),
            for (var detail in details)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
