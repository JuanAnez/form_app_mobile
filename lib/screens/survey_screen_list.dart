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
        title: const Text('Plantillas Destacadas'),
        backgroundColor: Colors.blue[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              _spaceBox(),
              CardWidget(
                imagePath: 'assets/images/post_event_survey_front.jpg',
                title: 'Encuesta de satisfacción de los empleados',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostEventSurvey(
                        imagePath: 'assets/images/post_event_survey_front.jpg',
                        title: 'Encuesta de satisfacción de los empleados',
                      ),
                    ),
                  );
                },
              ),
              _spaceBox(),
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
              CardWidget(
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
    );
  }

  Widget _spaceBox() {
    return const SizedBox(height: 20);
  }
}
