// filepath: /home/janez/Documents/forms/lib/screens/login/login_screen.dart

// filepath: /home/janez/Documents/forms/lib/screens/login/login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:forms/screens/loading/loading_data_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _signInWithEmailAndPassword(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Por favor, ingrese su correo electrónico y contraseña'),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      context.go('/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';

      if (e.code == 'user-not-found') {
        errorMessage = 'No existe una cuenta con este correo.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta. Inténtalo de nuevo.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Correo electrónico no válido.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Demasiados intentos. Intenta más tarde.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'Tu cuenta ha sido deshabilitada.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Credenciales inválidas o expiradas.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.black.withOpacity(0.8),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double padding = isTablet ? 80 : 40;

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
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Bienvenido!",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 45 : 35,
                        ),
                      ),
                      const SizedBox(height: 50),
                      _buildCustomTextField("Correo Electrónico", false),
                      const SizedBox(height: 16),
                      _buildCustomTextField("Contraseña", true),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
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
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 30),
                      Center(child: _buildGoogleSignInButton()),
                      const SizedBox(height: 40),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.go('/register');
                          },
                          child: const Text(
                            "Crear una cuenta",
                            style: TextStyle(color: Colors.white),
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

  Widget _buildCustomTextField(String hint, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: isPassword ? _passwordController : _emailController,
        obscureText: isPassword && !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black54,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Column(
      children: [
        MaterialButton(
          onPressed:
              _isLoading ? null : () => _signInWithEmailAndPassword(context),
          color: const Color.fromARGB(255, 116, 59, 143),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          height: 50,
          child: const Center(
            child: Text(
              "Iniciar Sesion",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildDivider() {
  return Row(
    children: [
      const Expanded(
        child: Divider(
          color: Colors.white70, // Color de la línea
          thickness: 1, // Grosor de la línea
          endIndent: 10, // Espacio antes del texto
        ),
      ),
      const Text(
        "O Inicia sesión con",
        style: TextStyle(
          fontFamily: 'Lato',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const Expanded(
        child: Divider(
          color: Colors.white70, // Color de la línea
          thickness: 1, // Grosor de la línea
          indent: 10, // Espacio después del texto
        ),
      ),
    ],
  );
}
