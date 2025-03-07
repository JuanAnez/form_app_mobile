import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/survey/list_maked_survey.dart';
import 'screens/survey/survey_response_screen.dart';
import 'screens/survey/survey_results_screen.dart' as results;
import 'screens/survey_screen_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        redirect: (context, state) =>
            FirebaseAuth.instance.currentUser == null ? '/login' : null,
      ),
      GoRoute(
        path: '/responder/:surveyId',
        builder: (context, state) {
          final surveyId = state.pathParameters['surveyId']!;
          return SurveyResponseScreen(surveyId: surveyId);
        },
      ),
      GoRoute(
        path: '/resultados/:surveyId',
        builder: (context, state) {
          final surveyId = state.pathParameters['surveyId']!;
          return results.SurveyResultsScreen(surveyId: surveyId);
        },
        redirect: (context, state) =>
            FirebaseAuth.instance.currentUser == null ? '/login' : null,
      ),
      GoRoute(
        path: '/listasEcuestas',
        builder: (context, state) => const ListMakedSurvey(),
        redirect: (context, state) =>
            FirebaseAuth.instance.currentUser == null ? '/login' : null,
      ),
      GoRoute(
        path: '/listasModelos',
        builder: (context, state) => const SurveyScreenList(),
        redirect: (context, state) =>
            FirebaseAuth.instance.currentUser == null ? '/login' : null,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseAuth>(
      create: (_) => FirebaseAuth.instance,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
      ),
    );
  }
}
