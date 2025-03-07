import 'package:flutter/material.dart';

class InvitationScreen extends StatelessWidget {
  const InvitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey'),
      ),
      body: const Center(
        child: Text('Survey Screen'),
      ),
    );
  }
}