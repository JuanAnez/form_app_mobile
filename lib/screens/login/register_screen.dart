// filepath: /home/janez/Documents/forms/lib/screens/login/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _registerWithEmailAndPassword(BuildContext context) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada. Por favor, verifica tu correo electrónico')),
      );
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
                        "Crear una cuenta",
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
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Password",
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: TextField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Confirm Password",
                                  hintStyle: TextStyle(color: Colors.grey.shade700),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                  const SizedBox(
                    height: 60,
                  ),
                  FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: MaterialButton(
                        onPressed: () => _registerWithEmailAndPassword(context),
                        color: const Color.fromRGBO(49, 39, 79, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        height: 50,
                        child: const Center(
                          child: Text(
                            "Registrar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
