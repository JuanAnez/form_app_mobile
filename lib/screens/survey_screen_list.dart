import 'package:flutter/material.dart';
import 'package:forms/screens/survey/post_event_survey.dart';
import 'package:forms/widgets/card_widget.dart';
import 'package:go_router/go_router.dart';

class SurveyScreenList extends StatelessWidget {
  const SurveyScreenList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantillas Destacadas',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 13, 148, 189),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Color.fromARGB(255, 74, 8, 105),
            height: 1.0,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF88DFFA), Color(0xFFA667C3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          child: Center(
            child: Column(
              children: [
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/post_event_survey_front.jpg',
                  title: 'Encuesta de satisfacción de los empleados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath:
                              'assets/images/post_event_survey_front.jpg',
                          title: 'Encuesta de satisfacción de los empleados',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/course-evaluation.jpg',
                  title: 'Encuesta de evaluación del curso',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/course-evaluation.jpg',
                          title: 'Encuesta de evaluación del curso',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/post_event_survey_back_hubble.jpg',
                  title: 'Encuesta de opinión después del evento',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath:
                              'assets/images/post_event_survey_back_hubble.jpg',
                          title: 'Encuesta de opinión después del evento',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/customer-survey.png',
                  title: 'Encuesta de satisfacción del cliente',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/customer-survey.png',
                          title: 'Encuesta de satisfacción del cliente',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/competitive_analysis.jpg',
                  title: 'Estudio de análisis competitivo',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/competitive_analysis.jpg',
                          title: 'Estudio de análisis competitivo',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/vacation.jpg',
                  title: 'Formulario de vacaciones y de baja por enfermedad',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/vacation.jpg',
                          title:
                              'Formulario de vacaciones y de baja por enfermedad',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/customer-expectation-survey.jpg',
                  title: 'Encuesta de expectativas del cliente',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath:
                              'assets/images/customer-expectation-survey.jpg',
                          title: 'Encuesta de expectativas del cliente',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/product-pricing-survey.jpg',
                  title: 'Encuesta de precios de un producto',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/product-pricing-survey.jpg',
                          title: 'Encuesta de precios de un producto',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/new_product.jpg',
                  title: 'Encuesta de lanzamiento de un nuevo producto',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/new_product.jpg',
                          title: 'Encuesta de lanzamiento de un nuevo producto',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/data-analysis2.jpg',
                  title: 'Encuesta de estudio de datos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/data-analysis2.jpg',
                          title: 'Encuesta de estudio de datos',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/entertainment_survey.jpg',
                  title: 'Encuesta de opinión sobre entretenimiento',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/entertainment_survey.jpg',
                          title: 'Encuesta de opinión sobre entretenimiento',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/remote_learning.jpg',
                  title: 'Encuesta de aprendizaje remoto',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/remote_learning.jpg',
                          title: 'Encuesta de aprendizaje remoto',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/interview-talk.jpg',
                  title: 'Encuesta de entrevista y charla',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/interview-talk.jpg',
                          title: 'Encuesta de entrevista y charla',
                        ),
                      ),
                    );
                  },
                ),
                _spaceBox(),
                CardWidgetSmall(
                  imagePath: 'assets/images/teacher_feedback.jpg',
                  title: 'Encuesta de comentarios del profesor',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PostEventSurvey(
                          imagePath: 'assets/images/teacher_feedback.jpg',
                          title: 'Encuesta de comentarios del profesor',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _spaceBox() {
    return const SizedBox(height: 20);
  }
}
