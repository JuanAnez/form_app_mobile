// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:ui' as ui;

class SurveyResultsScreen extends StatelessWidget {
  final String surveyId;

  const SurveyResultsScreen({super.key, required this.surveyId});

  Future<void> _shareSurveyResultsAsPDF(BuildContext context) async {
    DocumentSnapshot surveySnapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(surveyId)
        .get();

    if (!surveySnapshot.exists || surveySnapshot.data() == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Encuesta no encontrada')),
        );
      }
      return;
    }

    Map<String, dynamic> surveyData =
        surveySnapshot.data() as Map<String, dynamic>;
    List<dynamic> questions = surveyData['questions'] ?? [];

    final pdf = pw.Document();

    // Generar imágenes de los gráficos antes de agregarlas al PDF
    List<Uint8List> chartImages = [];
    for (var question in questions) {
      Uint8List chartImage = await _generatePieChartImage(question['votes']);
      chartImages.add(chartImage);
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          List<pw.Widget> pdfContent = [
            pw.Text("Resultados de la encuesta: ${surveyData['title']}",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
          ];

          for (int i = 0; i < questions.length; i++) {
            var question = questions[i];
            Map<String, dynamic> votes = question['votes'] ?? {};
            int totalVotes = votes.values
                .fold(0, (sum, count) => sum + (count as int? ?? 0));

            pdfContent.addAll([
              pw.Text(question['text'] ?? "Pregunta sin texto",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Lista de opciones con porcentaje al lado
              for (var entry in votes.entries)
                pw.Text(
                  "${entry.key}: ${entry.value ?? 0} votos (${(entry.value / totalVotes * 100).toStringAsFixed(1)}%)",
                  style: pw.TextStyle(fontSize: 14),
                ),
              pw.SizedBox(height: 10),

              // Imagen del gráfico
              pw.Center(
                child: pw.Image(pw.MemoryImage(chartImages[i]), height: 200),
              ),
              pw.SizedBox(height: 20),
            ]);
          }

          return pdfContent;
        },
      ),
    );

    final pdfFile = await pdf.save();

    if (context.mounted) {
      await Printing.sharePdf(
          bytes: pdfFile, filename: 'resultados_encuesta.pdf');
    }
  }

  Future<Uint8List> _generatePieChartImage(Map<String, dynamic> votes) async {
    final totalVotes =
        votes.values.fold(0, (sum, count) => sum + (count as int? ?? 0));

    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromPoints(Offset(0, 0), Offset(400, 400)));
    final paint = Paint()..color = Colors.white;
    canvas.drawPaint(paint);

    double startAngle = 0.0;
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
    ];

    int index = 0;
    votes.forEach((option, count) {
      if (count != null && count > 0) {
        double angleInDegrees = (count / totalVotes) * 360;
        final paint = Paint()..color = colors[index % colors.length];

        // Dibuja el sector del gráfico
        canvas.drawArc(
          Rect.fromLTWH(50, 50, 300, 300),
          startAngle * (pi / 180),
          angleInDegrees * (pi / 180),
          true,
          paint,
        );

        // Calcular posición del texto en el centro de cada segmento
        double midAngle = (startAngle + angleInDegrees / 2) * (pi / 180);
        double labelX = 200 + (120 * cos(midAngle));
        double labelY = 200 + (120 * sin(midAngle));

        // Dibujar solo el porcentaje sin la cantidad de votos
        final textPainter = TextPainter(
          text: TextSpan(
            text:
                "${((count / totalVotes) * 100).toStringAsFixed(1)}%", // 🔹 Solo porcentaje
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(labelX, labelY));

        startAngle += angleInDegrees;
        index++;
      }
    });

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 400);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

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
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () => _shareSurveyResultsAsPDF(context),
            ),
          ],
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
