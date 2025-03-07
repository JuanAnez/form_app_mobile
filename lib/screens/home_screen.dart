import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/screens/quiz_screen.dart';
import 'package:forms/screens/registration_screen.dart';
import 'package:forms/widgets/card_widget.dart';
import 'package:forms/widgets/submit_button_widget.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          Future.microtask(() =>
              context.go('/login')); // Evitar errores de navegación en `build`
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Forms'),
              backgroundColor: Colors.blue[200],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(
                  color: Colors.blue[300],
                  height: 4.0,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    context.go('/login');
                  },
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _spaceBox(),
                      const SubmitButtonWidget(),
                      _spaceBox(),
                      CardWidget(
                        imagePath: 'assets/images/survey-portal.png',
                        title: 'Crear Encuesta',
                        onTap: () {
                          context.go('/listasModelos');
                        },
                      ),
                      _spaceBox(),
                      CardWidget(
                        imagePath: 'assets/images/registration-portal.png',
                        title: 'Encuestas realizadas',
                        onTap: () {
                          context.go('/listasEcuestas');
                        },
                      ),
                      _spaceBox(),
                      CardWidget(
                        imagePath: 'assets/images/quiz-portal.png',
                        title: 'Cuestionario',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QuizScreen()),
                          );
                        },
                      ),
                      _spaceBox(),
                      CardWidget(
                        imagePath: 'assets/images/invitation-portal.png',
                        title: 'Invitacion',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen()),
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
      },
    );
  }

  Widget _spaceBox() {
    return const SizedBox(height: 20);
  }
}
