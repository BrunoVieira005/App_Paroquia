import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projeto_extensao/main.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool isLoading = false;

  // Função para adicionar um evento
  Future<void> _addEvent(String title, String description) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione a data e hora do evento.'),
        ),
      );
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('events').add({
        'title': title,
        'description': description,
        'eventDateTime': eventDateTime,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Evento criado com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao criar evento: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para editar um evento
  Future<void> _editEvent(
    String eventId,
    String newTitle,
    String newDescription,
  ) async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione a nova data e hora do evento.'),
        ),
      );
      return;
    }

    final newEventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('events').doc(eventId).update({
        'title': newTitle,
        'description': newDescription,
        'eventDateTime': newEventDateTime,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Evento editado com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao editar evento: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Função para excluir um evento
  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Evento excluído com sucesso!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao excluir evento: $e')));
    }
  }

  // Buscar eventos
  Future<List<Map<String, dynamic>>> _fetchEvents() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('events').orderBy('eventDateTime').get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'eventDateTime': (doc['eventDateTime'] as Timestamp).toDate(),
        };
      }).toList();
    } catch (e) {
      print('Erro ao carregar eventos: $e');
      return [];
    }
  }

  Future<void> _selectDateTime() async {
    await _selectDate(context);
    await _selectTime(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Novo Evento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  await _selectDateTime(); // Escolher data/hora
                  _addEvent(
                    titleController.text.trim(),
                    descController.text.trim(),
                  );
                },
                child: Text('Criar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(
    String id,
    String currentTitle,
    String currentDesc,
  ) async {
    TextEditingController titleController = TextEditingController(
      text: currentTitle,
    );
    TextEditingController descController = TextEditingController(
      text: currentDesc,
    );

    await _selectDateTime();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Editar Evento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _editEvent(id, titleController.text, descController.text);
                  Navigator.of(context).pop();
                },
                child: Text('Salvar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Eventos'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
          icon: Icon(Icons.home_outlined),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Erro ao carregar eventos'));

          final events = snapshot.data ?? [];
          if (events.isEmpty)
            return Center(child: Text('Nenhum evento encontrado.'));

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final dateStr = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(event['eventDateTime']);
              return ListTile(
                title: Text(event['title']),
                subtitle: Text('${event['description']}\n$dateStr'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteEvent(event['id']),
                ),
                onTap:
                    () => _showEditDialog(
                      event['id'],
                      event['title'],
                      event['description'],
                    ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
