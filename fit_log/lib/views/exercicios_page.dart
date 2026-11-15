import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORT DO BANCO DE DADOS

class ExerciciosPage extends StatefulWidget {
  const ExerciciosPage({super.key});

  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  // Conexão com a coleção "exercicios" lá no teu site do Firebase
  final CollectionReference _exerciciosRef =
  FirebaseFirestore.instance.collection('exercicios');

  final _nomeController = TextEditingController();
  final _grupoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Função para abrir o formulário (Salva ou Atualiza no Firebase)
  void _abrirFormulario({String? docId, String? nomeAtual, String? grupoAtual}) {
    if (docId != null) {
      _nomeController.text = nomeAtual!;
      _grupoController.text = grupoAtual!;
    } else {
      _nomeController.clear();
      _grupoController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Novo Exercício' : 'Editar Exercício'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome do Exercício (Ex: Supino)'),
                  validator: (value) => value!.isEmpty ? 'Digite o nome' : null,
                ),
                TextFormField(
                  controller: _grupoController,
                  decoration: const InputDecoration(labelText: 'Grupo Muscular (Ex: Peito)'),
                  validator: (value) => value!.isEmpty ? 'Digite o grupo muscular' : null,
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
                    // OPERAÇÃO: CREATE (Adiciona um novo documento no Firebase)
                    await _exerciciosRef.add({
                      'nome': _nomeController.text,
                      'grupo': _grupoController.text,
                    });
                  } else {
                    // OPERAÇÃO: UPDATE (Atualiza um documento existente no Firebase)
                    await _exerciciosRef.doc(docId).update({
                      'nome': _nomeController.text,
                      'grupo': _grupoController.text,
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
        title: const Text('Meus Exercícios'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // OPERAÇÃO: READ (Fica escutando o banco de dados em tempo real)
      body: StreamBuilder<QuerySnapshot>(
        stream: _exerciciosRef.snapshots(),
        builder: (context, snapshot) {
          // Se estiver a carregar os dados do Firebase
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Se o banco estiver vazio
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum exercício salvo no Firebase ainda.'),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id; // ID único do registro no Firebase

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.blue),
                  title: Text(data['nome'] ?? ''),
                  subtitle: Text('Grupo: ${data['grupo'] ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão de Editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _abrirFormulario(
                          docId: docId,
                          nomeAtual: data['nome'],
                          grupoAtual: data['grupo'],
                        ),
                      ),
                      // Botão de Eliminar (OPERAÇÃO: DELETE)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _exerciciosRef.doc(docId).delete();
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