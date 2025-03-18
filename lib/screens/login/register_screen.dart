// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/screens/loading/loading_data_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "555779524183-lbkip9sjkgd1nmnun89ck86stp9pk3ag.apps.googleusercontent.com",
  );

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoadingDataScreen()),
    );
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
                _emailController.text = email;
                Navigator.pop(context);
              },
              child: const Text('Iniciar sesión'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerWithEmailAndPassword(BuildContext context) async {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Crear usuario con email y password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Actualizar el nombre del usuario en Firebase
      await userCredential.user?.updateDisplayName(_fullNameController.text);

      // Enviar verificación de correo
      await userCredential.user?.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Verifica tu correo.')),
      );

      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double paddingHorizontal = isTablet ? 80 : 40;
          double titleFontSize = isTablet ? 28 : 20;

          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF88DFFA), Color(0xFFA667C3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0, top: 10),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                context.go('/login');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        "Crear una cuenta",
                        style: TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: titleFontSize,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildCustomTextField(
                          "Nombre Completo", _fullNameController, false),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                          "Correo Electrónico", _emailController, false),
                      const SizedBox(height: 16),
                      _buildCustomTextField(
                          "Ingresa una Contraseña", _passwordController, true),
                      const SizedBox(height: 24),
                      _buildSignUpButton(),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.go('/forgotPassword');
                          },
                          child: const Text(
                            "Olvidaste tu Contraseña?",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      Center(child: _buildGoogleSignInButton()),
                      const SizedBox(height: 40),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: const Text(
                            "Ya tienes una cuenta? Inicia sesión",
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomTextField(
      String hint, TextEditingController controller, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
        style: const TextStyle(fontFamily: 'Lato', color: Colors.white),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return MaterialButton(
      onPressed: () => _registerWithEmailAndPassword(context),
      color: const Color.fromARGB(255, 116, 59, 143),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      height: 50,
      minWidth: double.infinity,
      child: const Text(
        "Registrarse",
        style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(color: Colors.white54, thickness: 1),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "O Inicia sesión con",
            style: TextStyle(
                fontFamily: 'Lato', color: Colors.white70, fontSize: 14),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white54, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return GestureDetector(
      onTap: () {
        _signInWithGoogle(context);
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/images/google-icon.png',
            height: 30,
          ),
        ),
      ),
    );
  }
}
