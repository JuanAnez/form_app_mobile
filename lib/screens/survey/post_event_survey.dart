// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PostEventSurvey extends StatefulWidget {
  final String imagePath;
  final String title;

  const PostEventSurvey(
      {super.key, required this.imagePath, required this.title});

  @override
  _PostEventSurveyState createState() => _PostEventSurveyState();
}

class _PostEventSurveyState extends State<PostEventSurvey> {
  final TextEditingController newQuestionController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  String surveyId = '';
  DateTime? selectedDeadlineDate;
  TimeOfDay? selectedDeadlineTime;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
  }

  @override
  void dispose() {
    newQuestionController.dispose();
    titleController.dispose();
    for (var question in questions) {
      for (var option in question["options"]) {
        option["controller"].dispose();
      }
    }
    super.dispose();
  }

  Future<void> _selectDeadlineDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3)),
    );
    if (picked != null && picked != selectedDeadlineDate) {
      setState(() {
        selectedDeadlineDate = picked;
      });
    }
  }

  Future<void> _selectDeadlineTime(BuildContext context) async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null && picked != selectedDeadlineTime) {
      setState(() {
        selectedDeadlineTime = picked;
      });
    }
  }

  DateTime? get selectedDeadline {
    if (selectedDeadlineDate != null && selectedDeadlineTime != null) {
      return DateTime(
        selectedDeadlineDate!.year,
        selectedDeadlineDate!.month,
        selectedDeadlineDate!.day,
        selectedDeadlineTime!.hour,
        selectedDeadlineTime!.minute,
      );
    }
    return null;
  }

  Future<void> saveSurvey() async {
    if (titleController.text.isEmpty ||
        questions.isEmpty ||
        selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Por favor, añade un título, al menos una pregunta y una fecha límite")),
      );
      return;
    }

    List<Map<String, dynamic>> questionsToSave = questions.map((question) {
      Map<String, int> votesMap = {};
      for (var option in question["options"]) {
        votesMap[option["text"]] = question["votes"][option["text"]] ?? 0;
      }
      return {
        "text": question["text"],
        "options": question["options"]
            .map((option) => {"text": option["text"]})
            .toList(),
        "votes": votesMap,
      };
    }).toList();

    try {
      DocumentReference surveyRef =
          await FirebaseFirestore.instance.collection('surveys').add({
        'title': titleController.text,
        'questions': questionsToSave,
        'createdAt': FieldValue.serverTimestamp(),
        'deadline': selectedDeadline,
        'imagePath': widget.imagePath, // Save the image path
      });

      if (!mounted) return;

      setState(() {
        surveyId = surveyRef.id;
      });

      String responseUrl = "https://encuesta-62cf6.web.app/#/responder/$surveyId";
      String resultsUrl = "https://encuesta-62cf6.web.app/#/resultados/$surveyId";

      print("🔹 Responder encuesta URL: $responseUrl");
      print("🔹 Ver resultados URL: $resultsUrl");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Encuesta guardada. Comparte el enlace para responder.")),
        );
      }

      Share.share(
          "📋 Responde la encuesta: $responseUrl\n📊 Ver resultados: $resultsUrl");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la encuesta: $e')),
        );
      }
    }

    if (mounted) {
      GoRouter.of(context)
          .go("/listasEcuestas"); // Navigate to the appropriate page
    }
  }

  void addQuestion() {
    if (newQuestionController.text.isNotEmpty) {
      setState(() {
        questions.add({
          "text": newQuestionController.text,
          "options": [
            {"text": "Sí", "controller": TextEditingController(text: "Sí")},
            {"text": "No", "controller": TextEditingController(text: "No")}
          ],
          "votes": {"Sí": 0, "No": 0},
        });
        newQuestionController.clear();
      });
    }
  }

  void removeQuestion(int index) {
    setState(() {
      for (var option in questions[index]["options"]) {
        option["controller"].dispose();
      }
      questions.removeAt(index);
    });
  }

  void addOption(int questionIndex) {
    setState(() {
      String newOptionText =
          "Opción ${questions[questionIndex]["options"].length + 1}";
      questions[questionIndex]["options"].add({
        "text": newOptionText,
        "controller": TextEditingController(text: newOptionText),
      });
      questions[questionIndex]["votes"][newOptionText] = 0;
    });
  }

  void removeOption(int questionIndex, int optionIndex) {
    setState(() {
      String optionText =
          questions[questionIndex]["options"][optionIndex]["text"];
      questions[questionIndex]["options"][optionIndex]["controller"].dispose();
      questions[questionIndex]["options"].removeAt(optionIndex);
      questions[questionIndex]["votes"].remove(optionText);
    });
  }


  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMM yyyy').format(now);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: false,
          iconTheme: const IconThemeData(color: Colors.white),
          title: TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Ingrese el título',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.brown[300],
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveSurvey,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Image.asset(widget.imagePath),
                        const SizedBox(height: 10),
                        TextField(
                          controller: titleController,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ingrese el título',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("$formattedDate\n¡Está invitado!",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text("Date Limit:"),
                      const SizedBox(width: 10),
                      Text(
                        selectedDeadlineDate != null
                            ? DateFormat('dd MMM yyyy')
                                .format(selectedDeadlineDate!)
                            : "No seleccionada",
                      ),
                      const SizedBox(width: 40),
                      ElevatedButton.icon(
                        onPressed: () => _selectDeadlineDate(context),
                        icon: const Icon(
                          Icons.date_range,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Select date",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          backgroundColor: const Color(0xFF005F72),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text("Hora límite:"),
                      const SizedBox(width: 10),
                      Text(
                        selectedDeadlineTime != null
                            ? selectedDeadlineTime!.format(context)
                            : "No seleccionada",
                      ),
                      const SizedBox(width: 34),
                      ElevatedButton.icon(
                        onPressed: () => _selectDeadlineTime(context),
                        icon: const Icon(
                          Icons.date_range,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Select hour",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          backgroundColor: const Color(0xFF00747F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...questions.asMap().entries.map((entry) {
                    int index = entry.key;
                    var question = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text("${index + 1}. ${question["text"]}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeQuestion(index),
                            ),
                          ],
                        ),
                        Column(
                          children: question["options"]
                              .asMap()
                              .entries
                              .map<Widget>((optionEntry) {
                            int optionIndex = optionEntry.key;
                            var option = optionEntry.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: option["controller"],
                                    onChanged: (value) {
                                      setState(() {
                                        option["text"] = value;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      removeOption(index, optionIndex),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => addOption(index),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text("Agregar opción",
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                  TextFormField(
                    controller: newQuestionController,
                    decoration: const InputDecoration(
                        labelText: "Agregar nueva pregunta",
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: addQuestion,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Agregar",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
