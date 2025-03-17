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
              backgroundColor: const Color.fromARGB(255, 13, 148, 189),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4.0),
                child: Container(
                  color: const Color.fromARGB(255, 74, 8, 105),
                  height: 1.0,
                ),
              ),
              actions: [
                if (photoUrl != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                  )
                else
                  const Icon(Icons.person, color: Colors.white),
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
                bool isTablet = constraints.maxWidth > 600;
                double cardWidth = isTablet ? 450 : double.infinity;
                double paddingHorizontal = isTablet ? 60 : 10;

                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF88DFFA), Color(0xFFA667C3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: paddingHorizontal),
                      child: Column(
                        children: [
                          _buildCard(context, 'assets/images/survey-portal.png',
                              'Crear Encuesta', '/listasModelos', cardWidth),
                          _spaceBox(),
                          _buildCard(
                              context,
                              'assets/images/registration-portal.png',
                              'Encuestas realizadas',
                              '/listasEcuestas',
                              cardWidth),
                          _spaceBox(),
                          _buildCard(context, 'assets/images/quiz-portal.png',
                              'Cuestionario', '/quizScreen', cardWidth),
                          _spaceBox(),
                          _buildCard(
                              context,
                              'assets/images/invitation-portal.png',
                              'Invitación',
                              '/registrationScreen',
                              cardWidth),
                        ],
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

  Widget _buildCard(BuildContext context, String imagePath, String title,
      String route, double width) {
    return SizedBox(
      width: width,
      child: CardWidget(
        imagePath: imagePath,
        title: title,
        onTap: () {
          context.go(route);
        },
      ),
    );
  }

  Widget _spaceBox() {
    return const SizedBox(height: 20);
  }
}
