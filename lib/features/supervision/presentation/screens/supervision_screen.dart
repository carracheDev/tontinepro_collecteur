import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SupervisionScreen extends StatelessWidget {
  const SupervisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supervision')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MiniMap(),
          SizedBox(height: 12),
          Card(child: ListTile(leading: Icon(Icons.person), title: Text('Agent Kossi'), subtitle: Text('92% performance'))),
          SizedBox(height: 10),
          Card(child: ListTile(leading: Icon(Icons.person), title: Text('Agent Sika'), subtitle: Text('78% performance'))),
          SizedBox(height: 10),
          Card(child: ListTile(leading: Icon(Icons.info), title: Text('Aucun acces collecte ou scanner'))),
        ],
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bordure),
      ),
      child: const Center(
        child: Icon(Icons.map, color: AppColors.primaryDark, size: 70),
      ),
    );
  }
}
