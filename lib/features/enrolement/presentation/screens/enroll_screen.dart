import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/app_router.dart';

class EnrollScreen extends StatefulWidget {
  const EnrollScreen({super.key});

  @override
  State<EnrollScreen> createState() => _EnrollScreenState();
}

class _EnrollScreenState extends State<EnrollScreen> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrolement client')),
      body: Stepper(
        currentStep: step,
        onStepContinue: () {
          if (step == 3) {
            context.pushReplacement(Routes.enrollSuccess);
          } else {
            setState(() => step++);
          }
        },
        onStepCancel: step == 0 ? null : () => setState(() => step--),
        steps: const [
          Step(title: Text('Infos'), content: _EnrollFields(labels: ['Nom', 'Telephone client'])),
          Step(title: Text('KYC'), content: _EnrollFields(labels: ['Piece ID', 'Adresse'])),
          Step(title: Text('Tontine initiale'), content: _EnrollFields(labels: ['Montant journalier', 'Objectif'])),
          Step(title: Text('Consentement'), content: Text('Validation client et accord OTP requis.')),
        ],
      ),
    );
  }
}

class _EnrollFields extends StatelessWidget {
  const _EnrollFields({required this.labels});
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: labels
          .map(
            (label) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(decoration: InputDecoration(labelText: label)),
            ),
          )
          .toList(),
    );
  }
}
