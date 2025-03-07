// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class SurveyResultsScreen extends StatelessWidget {
  final String surveyId;

  const SurveyResultsScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[200],
          title: const Text("Resultados de la Encuesta"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/listasEcuestas');
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('surveys')
                  .doc(surveyId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                Map<String, dynamic> surveyData =
                    snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> questions = surveyData['questions'];

                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var question = questions[index];
                    Map<String, dynamic> votes = question['votes'];

                    // Total de votos
                    int totalVotes = votes.values
                        .fold(0, (sum, count) => sum + (count as int? ?? 0));

                    // Lista de colores predefinidos para las opciones
                    List<Color> colors = [
                      Colors.blue,
                      Colors.red,
                      Colors.green,
                      Colors.orange,
                      Colors.purple,
                      Colors.cyan
                    ];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(question['text'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),

                        // Mostrar gráfico de pastel si hay votos
                        if (totalVotes > 0)
                          SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 1, // Espacio entre secciones
                                centerSpaceRadius: 45, // Espacio central
                                sections: votes.entries
                                    .where((entry) =>
                                        entry.value != null &&
                                        entry.value! > 0) // 🔹 Filtra valores 0
                                    .map((entry) {
                                  double percentage =
                                      (entry.value ?? 0) / totalVotes * 100;
                                  int colorIndex =
                                      votes.keys.toList().indexOf(entry.key) %
                                          colors.length;

                                  return PieChartSectionData(
                                    value: percentage,
                                    color: colors[colorIndex],
                                    radius: 100,
                                    title:
                                        "${percentage.toStringAsFixed(2)}%", // 🔹 Limita a 2 decimales
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Text(
                              "Aún no hay votos para esta encuesta.",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),

                        // Mostrar votos en texto
                        Column(
                          children: votes.entries.map<Widget>((entry) {
                            double percentage = totalVotes > 0
                                ? (entry.value ?? 0) / totalVotes * 100
                                : 0;
                            int colorIndex =
                                votes.keys.toList().indexOf(entry.key) %
                                    colors.length;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    colors[colorIndex], // Color correspondiente
                                radius: 10,
                              ),
                              title: Text(
                                "${entry.key}: ${entry.value ?? 0} votos (${percentage.toStringAsFixed(1)}%)",
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                        ),

                        const Divider(),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
