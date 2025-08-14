import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CalendarioEventosPage extends StatefulWidget {
  @override
  _CalendarioEventosPageState createState() => _CalendarioEventosPageState();
}

class _CalendarioEventosPageState extends State<CalendarioEventosPage> {
  DateTime currentMonth = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  late List<String> daysOfWeek;
  late List<String> daysInMonth;
  List<Map<String, dynamic>> eventosDoMes = [];
  Map<String, String> tipoPorData = {};

  @override
  void initState() {
    super.initState();
    daysOfWeek = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    _generateDaysInMonth(currentMonth);
    _loadEventosDoMes();
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
      _generateDaysInMonth(currentMonth);
      _loadEventosDoMes();
    });
  }

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
      _generateDaysInMonth(currentMonth);
      _loadEventosDoMes();
    });
  }

  void _generateDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final numDays = lastDayOfMonth.day;

    daysInMonth = List.generate(numDays, (index) {
      final day = index + 1;
      return (day < 10) ? '0$day' : '$day';
    });

    int emptyStart = firstDayOfMonth.weekday % 7;
    for (int i = 0; i < emptyStart; i++) {
      daysInMonth.insert(0, '');
    }
  }

  Future<void> _loadEventosDoMes() async {
    final inicio = DateTime(currentMonth.year, currentMonth.month, 1);
    final fim = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
      23,
      59,
      59,
    );

    final snapshot =
        await FirebaseFirestore.instance
            .collection('events')
            .where('eventDateTime', isGreaterThanOrEqualTo: inicio)
            .where('eventDateTime', isLessThanOrEqualTo: fim)
            .orderBy('eventDateTime')
            .get();

    tipoPorData.clear();

    final eventos =
        snapshot.docs.map((doc) {
          final dataHora = (doc['eventDateTime'] as Timestamp).toDate();
          final dataFormatada = formatter.format(dataHora);
          tipoPorData[dataFormatada] = 'FIREBASE';

          return {
            'title': doc['title'],
            'description': doc['description'],
            'dataHora': dataHora,
          };
        }).toList();

    setState(() {
      eventosDoMes = eventos;
    });
  }

  Color? _corDoDia(String dia) {
    if (dia.isEmpty) return null;
    final data = formatter.format(
      DateTime(currentMonth.year, currentMonth.month, int.parse(dia)),
    );

    if (data == formatter.format(DateTime.now())) {
      return Colors.orangeAccent;
    }

    if (tipoPorData[data] == 'FIREBASE') {
      return Colors.lightGreenAccent;
    }

    return null;
  }

  Widget _buildLegenda(Color cor, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          margin: EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String monthYear = DateFormat.yMMMM('pt_BR').format(currentMonth);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.brown),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fundo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 60),
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
              Text(
                'Calendário de Eventos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.brown),
                    onPressed: previousMonth,
                  ),
                  Text(
                    monthYear.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.brown,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Colors.brown),
                    onPressed: nextMonth,
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          daysOfWeek
                              .map(
                                (day) => Expanded(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    // Remova o espaço aqui
                    GridView.builder(
                      padding: EdgeInsets.only(
                        top: 20,
                      ), // Adicione padding zero no topo
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: daysInMonth.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final day = daysInMonth[index];
                        return Container(
                          margin: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: _corDoDia(day),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    day.isEmpty
                                        ? Colors.transparent
                                        : Colors.brown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegenda(Colors.lightGreenAccent, 'Evento'),
                    _buildLegenda(Colors.orangeAccent, 'Hoje'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  "Eventos próximos",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              ...eventosDoMes.map((evento) {
                final DateTime dataHora = evento['dataHora'];
                final String dataFormatada = DateFormat(
                  'dd/MM/yyyy',
                ).format(dataHora);
                final String horaFormatada = DateFormat(
                  'HH:mm',
                ).format(dataHora);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 4.0,
                  ),
                  child: Card(
                    color: Colors.white.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        evento['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (evento['description'] != null &&
                              evento['description']
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(evento['description']),
                            ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.brown,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '$dataFormatada às $horaFormatada',
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
