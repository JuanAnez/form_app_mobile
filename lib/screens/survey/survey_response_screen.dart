// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:forms/services/local_database.dart';

class SurveyResponseScreen extends StatefulWidget {
  final String surveyId;

  const SurveyResponseScreen({super.key, required this.surveyId});

  @override
  _SurveyResponseScreenState createState() => _SurveyResponseScreenState();
}

class _SurveyResponseScreenState extends State<SurveyResponseScreen> {
  final LocalDatabase _localDatabase = LocalDatabase();
  Map<String, String> selectedAnswers = {};
  List<dynamic> questions = [];

  @override
  void initState() {
    super.initState();
    print("🛠 SurveyResponseScreen cargado con ID: ${widget.surveyId}");
    _syncResponses();
  }

  Future<void> _syncResponses({int retryCount = 0}) async {
    const int maxRetries = 5;
    const Duration initialDelay = Duration(seconds: 2);

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      List<Map<String, dynamic>> responses =
          await _localDatabase.getResponses();
      print("🔹 Syncing ${responses.length} responses");
      for (var response in responses) {
        print("🔹 Syncing response: $response");
        try {
          await _submitResponse(
            response['surveyId'],
            response['question'],
            response['answer'],
          );
        } catch (e) {
          print("🔹 Error syncing response: $e");
          if (retryCount < maxRetries) {
            await Future.delayed(initialDelay * (retryCount + 1));
            await _syncResponses(retryCount: retryCount + 1);
          } else {
            print("🔹 Max retries reached. Stopping sync.");
            break;
          }
        }
      }
      await _localDatabase.deleteResponses();
      print("🔹 All responses synced and local storage cleared");
    } else {
      print("🔹 No internet connection. Retrying sync.");
      if (retryCount < maxRetries) {
        await Future.delayed(initialDelay * (retryCount + 1));
        await _syncResponses(retryCount: retryCount + 1);
      } else {
        print("🔹 Max retries reached. Stopping sync.");
      }
    }
  }

  Future<void> _submitResponse(String surveyId, String question, String answer,
      {int retryCount = 0}) async {
    const int maxRetries = 5;
    const Duration initialDelay = Duration(seconds: 2);

    try {
      DocumentReference surveyRef =
          FirebaseFirestore.instance.collection('surveys').doc(surveyId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(surveyRef);

        Map<String, dynamic>? surveyData =
            snapshot.data() as Map<String, dynamic>?;

        if (surveyData == null || !surveyData.containsKey('questions')) {
          return;
        }

        questions = surveyData['questions'];
        List<dynamic> updatedQuestions = List.from(questions);

        for (var q in updatedQuestions) {
          if (q['text'] == question) {
            if (!q['votes'].containsKey(answer)) {
              q['votes'][answer] = 0;
            }
            q['votes'][answer] += 1;
          }
        }

        transaction.update(surveyRef, {'questions': updatedQuestions});
      });
    } catch (e) {
      if (e is FirebaseException &&
          e.code == 'unavailable' &&
          retryCount < maxRetries) {
        await Future.delayed(initialDelay * (retryCount + 1));
        await _submitResponse(surveyId, question, answer,
            retryCount: retryCount + 1);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar la respuesta: $e')),
          );
        }
      }
    }
  }

  Future<void> _storeVoteLocally(
      String surveyId, String question, String answer) async {
    await _localDatabase.insertResponse(surveyId, question, answer);
    print("🔹 Vote stored locally: $surveyId, $question, $answer");
  }

  Future<Map<String, dynamic>> fetchSurveyData() async {
    DocumentSnapshot surveySnapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(widget.surveyId)
        .get();

    if (!surveySnapshot.exists || surveySnapshot.data() == null) {
      throw Exception("Encuesta no encontrada o vacía.");
    }

    return surveySnapshot.data() as Map<String, dynamic>;
  }

  Future<void> submitResponses() async {
    // Verificar que todas las preguntas tengan una respuesta
    if (selectedAnswers.length != questions.length) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error en el envío"),
            content: const Text("Por favor, responda todas las preguntas antes de enviar."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    for (var question in questions) {
      if (!selectedAnswers.containsKey(question['text']) || selectedAnswers[question['text']]!.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Error"),
              content: const Text("Por favor, responda todas las preguntas antes de enviar."),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      for (var entry in selectedAnswers.entries) {
        await _storeVoteLocally(widget.surveyId, entry.key, entry.value);
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Información"),
              content: const Text("Respuestas guardadas localmente. Se enviarán cuando haya conexión."),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/listasEcuestas'); // Navigate to the appropriate page
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      for (var entry in selectedAnswers.entries) {
        await _submitResponse(widget.surveyId, entry.key, entry.value);
      }
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Éxito"),
              content: const Text("Respuestas enviadas correctamente"),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/listasEcuestas');
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[200],
          title: const Text("Responder Encuesta"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/listasEcuestas');
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return FutureBuilder<Map<String, dynamic>>(
              future: fetchSurveyData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                Map<String, dynamic> surveyData = snapshot.data!;
                questions = surveyData['questions'];

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(surveyData['title'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            var question = questions[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(question['text'],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                ...question['options'].map<Widget>((option) {
                                  return RadioListTile<String>(
                                    title: Text(option['text']),
                                    value: option['text'],
                                    groupValue:
                                        selectedAnswers[question['text']],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[question['text']] =
                                            value!;
                                      });
                                    },
                                  );
                                }).toList(),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: submitResponses,
                        child: const Text("Enviar Respuestas"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Pantalla de Resultados con Gráfico de Pastel
