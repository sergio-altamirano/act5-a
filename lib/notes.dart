import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Note extends StatefulWidget {
  const Note({super.key});

  @override
  State<Note> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<Note> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final CollectionReference _notesCollection = FirebaseFirestore.instance
      .collection('notes');

  @override
  void initState() {
    super.initState();
    // Debug: Verificar conexión a Firestore
    _testFirestoreConnection();
  }

  Future<void> _testFirestoreConnection() async {
    try {
      debugPrint('Conexión a Firestore exitosa. Existe colección "notes"');
    } catch (e) {
      debugPrint('Error de conexión a Firestore: $e');
    }
  }

  Future<void> _addNote() async {
    try {
      await _notesCollection.add({
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      _titleController.clear();
      _contentController.clear();
      debugPrint('Nota guardada exitosamente');
    } catch (e) {
      debugPrint('Error al guardar nota: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas Diarias Sergio Altamirano'),
        backgroundColor: const Color.fromARGB(255, 255, 156, 7),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulario de entrada (se mantiene igual)
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Contenido'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addNote,
              child: const Text('Guardar Nota'),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Tus Notas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Lista de notas - Versión debug
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _notesCollection
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  // Debug: Mostrar estado actual
                  debugPrint(
                    'Estado del StreamBuilder: ${snapshot.connectionState}',
                  );
                  debugPrint('Tiene datos?: ${snapshot.hasData}');
                  debugPrint('Tiene error?: ${snapshot.hasError}');

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    debugPrint('Error en StreamBuilder: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    debugPrint('No se encontraron documentos en la colección');
                    return const Center(
                      child: Text('No hay notas disponibles'),
                    );
                  }

                  // Debug: Mostrar datos recibidos
                  debugPrint(
                    'Número de documentos: ${snapshot.data!.docs.length}',
                  );
                  for (var doc in snapshot.data!.docs) {
                    debugPrint('Documento ID: ${doc.id}');
                    debugPrint('Datos: ${doc.data()}');
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(data['title'] ?? 'Sin título'),
                          subtitle: Text(data['content'] ?? 'Sin contenido'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => doc.reference.delete(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
