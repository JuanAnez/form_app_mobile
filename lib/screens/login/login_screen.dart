// filepath: /home/janez/Documents/forms/lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "555779524183-lbkip9sjkgd1nmnun89ck86stp9pk3ag.apps.googleusercontent.com",
  );

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // Intentar iniciar sesión normalmente con Google
        await FirebaseAuth.instance.signInWithCredential(googleCredential);
        context.go('/home');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // 🔥 El usuario ya tiene cuenta con otro proveedor
          String email = e.email!;
          List<String> providers =
              await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

          if (providers.contains('password')) {
            // Si el usuario ya tiene una cuenta con correo y contraseña
            _mostrarDialogoInicioSesion(email);
          } else if (providers.contains('facebook.com')) {
            // 🔥 Si la cuenta está asociada a Facebook, pedimos que inicie sesión con Facebook
            // _signInWithFacebook(context, googleCredential);
          }
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Future<void> _signInWithFacebook(BuildContext context,
  //     [AuthCredential? pendingCredential]) async {
  //   try {
  //     final LoginResult loginResult = await FacebookAuth.instance.login();

  //     if (loginResult.status == LoginStatus.success) {
  //       final OAuthCredential facebookCredential =
  //           FacebookAuthProvider.credential(
  //               loginResult.accessToken!.tokenString);

  //       UserCredential userCredential;
  //       if (pendingCredential != null) {
  //         // 🔥 Vincular cuenta con Google si hay credenciales pendientes
  //         userCredential = await FirebaseAuth.instance
  //             .signInWithCredential(facebookCredential);
  //         await userCredential.user?.linkWithCredential(pendingCredential);
  //       } else {
  //         // Iniciar sesión con Facebook normalmente
  //         userCredential = await FirebaseAuth.instance
  //             .signInWithCredential(facebookCredential);
  //       }

  //       final User? user = userCredential.user;

  //       if (user != null) {
  //         // 🔥 Obtener la foto de perfil de Facebook
  //         final userData = await FacebookAuth.instance.getUserData();
  //         final String? photoUrl = userData['picture']['data']['url'];

  //         if (photoUrl != null) {
  //           // 🔥 Actualizar la `photoURL` en Firebase
  //           await user.updatePhotoURL(photoUrl);
  //           await user.reload(); // Forzar actualización de datos del usuario
  //         }
  //       }

  //       context.go('/home'); // Redirigir al Home
  //     } else {
  //       throw Exception("Inicio de sesión cancelado.");
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  // }

  void _mostrarDialogoInicioSesion(String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cuenta existente'),
          content: Text(
              'Tu correo $email ya está registrado. Inicia sesión con tu contraseña.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _emailController.text = email; // Autocompletar email
                Navigator.pop(context);
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 300,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -40,
                    height: 300,
                    width: width,
                    child: FadeInUp(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/background.png'),
                                  fit: BoxFit.fill)),
                        )),
                  ),
                  Positioned(
                    height: 270,
                    width: width + 20,
                    child: FadeInUp(
                        duration: const Duration(milliseconds: 1000),
                        child: Container(
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/login-background2.png'),
                                  fit: BoxFit.fill)),
                        )),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: Color.fromRGBO(49, 39, 79, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      )),
                  const SizedBox(
                    height: 50,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            border: Border.all(
                                color: const Color.fromRGBO(196, 135, 198, .3)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(196, 135, 198, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              )
                            ]),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Color.fromRGBO(
                                              196, 135, 198, .3)))),
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Email",
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade700)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Password",
                                    hintStyle:
                                        TextStyle(color: Colors.grey.shade700)),
                              ),
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Center(
                          child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Color.fromRGBO(196, 135, 198, 1)),
                              )))), //COMO HAGO UN METODO DE RECUPERACION DE CONTRASENA
                  const SizedBox(
                    height: 30,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: MaterialButton(
                        onPressed: () => _signInWithEmailAndPassword(context),
                        color: const Color.fromRGBO(49, 39, 79, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        height: 50,
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                  const SizedBox(
                    height: 60,
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.go('/register');
                      },
                      child: const Text(
                        "Crear una cuenta",
                        style: TextStyle(
                            color: Color.fromRGBO(49, 39, 79,
                                1)), //COMO CREAR UNA CUENTA CON METODO DE VALIDACION DE CORREO ELECTRONICO
                      ),
                    ),
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1900),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: SignInButton(
                            Buttons.google,
                            onPressed: () {
                              _signInWithGoogle(context);
                            },
                          ),
                        ),
                        // Center(
                        //   child: SignInButton(
                        //     Buttons.facebookNew,
                        //     onPressed: () {
                        //       _signInWithFacebook(context);
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
