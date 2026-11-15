import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORT DO BANCO DE DADOS

class RegistrarTreinoPage extends StatefulWidget {
  const RegistrarTreinoPage({super.key});

  @override
  State<RegistrarTreinoPage> createState() => _RegistrarTreinoPageState();
}

class _RegistrarTreinoPageState extends State<RegistrarTreinoPage> {
  // Conexão com a coleção "treinos" lá no teu Firebase
  final CollectionReference _treinosRef =
  FirebaseFirestore.instance.collection('treinos');

  final _exercicioController = TextEditingController();
  final _detalhesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Função para abrir o formulário (Cria ou Atualiza no Firebase)
  void _abrirFormulario({String? docId, String? exercicioAtual, String? detalhesAtual}) {
    if (docId != null) {
      _exercicioController.text = exercicioAtual!;
      _detalhesController.text = detalhesAtual!;
    } else {
      _exercicioController.clear();
      _detalhesController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Registrar Treino' : 'Editar Registro'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _exercicioController,
                  decoration: const InputDecoration(labelText: 'Qual exercício você fez?'),
                  validator: (value) => value!.isEmpty ? 'Digite o exercício' : null,
                ),
                TextFormField(
                  controller: _detalhesController,
                  decoration: const InputDecoration(labelText: 'Séries e Carga (Ex: 4x12 - 30kg)'),
                  validator: (value) => value!.isEmpty ? 'Digite os detalhes' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (docId == null) {
                    // OPERAÇÃO: CREATE (Salva um novo treino no Firebase)
                    await _treinosRef.add({
                      'exercicio': _exercicioController.text,
                      'detalhes': _detalhesController.text,
                      'data': 'Hoje',
                    });
                  } else {
                    // OPERAÇÃO: UPDATE (Atualiza o treino existente no Firebase)
                    await _treinosRef.doc(docId).update({
                      'exercicio': _exercicioController.text,
                      'detalhes': _detalhesController.text,
                    });
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Treino Diário'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // OPERAÇÃO: READ (Lista os treinos salvos na nuvem em tempo real)
      body: StreamBuilder<QuerySnapshot>(
        stream: _treinosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum treino registrado no Firebase ainda.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(data['exercicio'] ?? ''),
                  subtitle: Text(data['detalhes'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _abrirFormulario(
                          docId: docId,
                          exercicioAtual: data['exercicio'],
                          detalhesAtual: data['detalhes'],
                        ),
                      ),
                      // Botão Eliminar (OPERAÇÃO: DELETE)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _treinosRef.doc(docId).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}