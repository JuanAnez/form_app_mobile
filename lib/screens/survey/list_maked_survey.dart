import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class ListMakedSurvey extends StatelessWidget {
  const ListMakedSurvey({super.key});

  Future<void> _deleteSurvey(BuildContext context, String surveyId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content:
              const Text('¿Está seguro de que desea eliminar esta encuesta?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await FirebaseFirestore.instance
          .collection('surveys')
          .doc(surveyId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encuesta eliminada')),
      );
    }
  }

  Future<void> _shareSurvey(BuildContext context, String surveyId) async {
    DocumentSnapshot surveySnapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(surveyId)
        .get();

    if (!surveySnapshot.exists || surveySnapshot.data() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encuesta no encontrada')),
      );
      return;
    }

    Map<String, dynamic> surveyData =
        surveySnapshot.data() as Map<String, dynamic>;

    // Verificar si la encuesta ha expirado
    Timestamp? deadlineTimestamp = surveyData['deadline'];
    bool isExpired = false;
    if (deadlineTimestamp != null) {
      DateTime deadline = deadlineTimestamp.toDate();
      if (DateTime.now().isAfter(deadline)) {
        isExpired = true;
      }
    }

    String responseUrl = "https://encuesta-62cf6.web.app/#/responder/$surveyId";
    String resultsUrl = "https://encuesta-62cf6.web.app/#/resultados/$surveyId";

    if (isExpired) {
      Share.share("📊 Ver resultados: $resultsUrl");
    } else {
      Share.share(
          "📋 Responde la encuesta: $responseUrl\n📊 Ver resultados: $resultsUrl");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Encuestas realizadas'),
          backgroundColor: Colors.blue[200],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go('/home');
            },
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _spaceBox(),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('surveys')
                        .where('userId',
                            isEqualTo: FirebaseAuth.instance.currentUser
                                ?.uid) // 🔹 Filtrar por usuario
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      var surveys = snapshot.data!.docs;

                      if (surveys.isEmpty) {
                        return const Center(
                            child: Text("No tienes encuestas creadas."));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: surveys.length,
                        itemBuilder: (context, index) {
                          var survey = surveys[index];
                          var surveyId = survey.id;
                          var surveyTitle = survey['title'];
                          var surveyData =
                              survey.data() as Map<String, dynamic>;
                          var imagePath = surveyData.containsKey('imagePath')
                              ? surveyData['imagePath']
                              : "assets/images/post_event_survey_front.jpg";

                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 32 / 7,
                                    child: Image.asset(imagePath,
                                        fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    surveyTitle,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8.0,
                                    runSpacing: 4.0,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            context.go('/responder/$surveyId'),
                                        icon: const Icon(Icons.quiz,
                                            color: Colors.white),
                                        label: const Text('Responder',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF00747F)),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            context.go('/resultados/$surveyId'),
                                        icon: const Icon(Icons.quiz,
                                            color: Colors.white),
                                        label: const Text('Ver Resultados',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF005F72)),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _deleteSurvey(context, surveyId),
                                        icon: const Icon(Icons.delete,
                                            color: Colors.white),
                                        label: const Text('Eliminar',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF00747F),
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _shareSurvey(context, surveyId),
                                        icon: const Icon(Icons.share,
                                            color: Colors.white),
                                        label: const Text('Compartir',
                                            style:
                                                TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF005F72)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _spaceBox() {
    return const SizedBox(height: 20);
  }
}
