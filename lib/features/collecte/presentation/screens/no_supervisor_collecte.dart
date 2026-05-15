import 'package:flutter/material.dart';

class NoSupervisorCollecte extends StatelessWidget {
  const NoSupervisorCollecte({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acces superviseur')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Le superviseur ne collecte jamais et n accede pas au scanner.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
