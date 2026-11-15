import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORT DO BANCO DE DADOS
import 'package:fit_log/views/exercicios_page.dart';
import 'package:fit_log/views/registrar_treino_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Conexão direta com a coleção de treinos do Firebase
    final CollectionReference treinosRef =
    FirebaseFirestore.instance.collection('treinos');

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitLog - Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      // MENU LATERAL (Drawer)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'FitLog Academia',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Início'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.blue),
              title: const Text('Gerenciar Exercícios'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ExerciciosPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_task, color: Colors.blue),
              title: const Text('Registrar Treino'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrarTreinoPage()));
              },
            ),
          ],
        ),
      ),

      // CORPO DA TELA INICIAL
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boas-vindas estilizado
            const Text(
              'Olá, Campeão! 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Aqui está o resumo do seu histórico de foco:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Título da seção de histórico
            const Row(
              children: [
                Icon(Icons.history, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Últimos Treinos Realizados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // LISTA EM TEMPO REAL DO FIREBASE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: treinosRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text(
                            'Nenhum treino no histórico.\nUse o menu para registrar o primeiro!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.offline_bolt, color: Colors.blue),
                          ),
                          title: Text(
                            data['exercicio']?.toString().toUpperCase() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Séries/Carga: ${data['detalhes'] ?? ''}'),
                          trailing: Text(
                            data['data'] ?? 'Hoje',
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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
}