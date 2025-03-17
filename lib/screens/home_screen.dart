// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/widgets/card_widget.dart';
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
          Future.microtask(() => context.go('/login'));
          return const SizedBox.shrink();
        }

        final user = snapshot.data;
        final photoUrl = user?.photoURL;
        final displayName = user?.displayName ?? 'Usuario';
        final email = user?.email ?? 'Correo no disponible';

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Forms',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    displayName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Text(
                    email,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                ],
              ),
              backgroundColor: Color.fromARGB(255, 13, 148, 189),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(
                  color: Color.fromARGB(255, 74, 8, 105),
                  height: 1.0,
                ),
              ),
              actions: [
                if (photoUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                  )
                else
                  const Icon(Icons.person),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
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
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF88DFFA), Color(0xFFA667C3)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(10),
                      child: Center(
                        child: Column(
                          children: [
                            CardWidget(
                              imagePath: 'assets/images/survey-portal.png',
                              title: 'Crear Encuesta',
                              onTap: () {
                                context.go('/listasModelos');
                              },
                            ),
                            _spaceBox(),
                            CardWidget(
                              imagePath:
                                  'assets/images/registration-portal.png',
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
                                context.go('/quizScreen');
                              },
                            ),
                            _spaceBox(),
                            CardWidget(
                              imagePath: 'assets/images/invitation-portal.png',
                              title: 'Invitacion',
                              onTap: () {
                                context.go('/registrationScreen');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
