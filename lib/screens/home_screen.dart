// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                  const Text('Forms'),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: Colors.blue[200],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(
                  color: Colors.blue[300],
                  height: 4.0,
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
                          context.go('/quiz');
                        },
                      ),
                      _spaceBox(),
                      CardWidget(
                        imagePath: 'assets/images/invitation-portal.png',
                        title: 'Invitacion',
                        onTap: () {
                          context.go('/registration');
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
