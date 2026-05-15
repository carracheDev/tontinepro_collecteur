import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class MissionsScreen extends StatelessWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missions agent')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ProgressLine(label: 'Prime journaliere', value: 0.68),
          Card(child: ListTile(leading: Icon(Icons.place), title: Text('Afi Akplogan'), subtitle: Text('Check-in GPS attendu'))),
          SizedBox(height: 10),
          Card(child: ListTile(leading: Icon(Icons.place), title: Text('Bio Sanni'), subtitle: Text('Retard 2 jours'))),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: value, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
