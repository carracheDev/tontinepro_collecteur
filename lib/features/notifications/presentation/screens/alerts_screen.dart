import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alertes'),
          bottom: const TabBar(tabs: [Tab(text: 'Mes alertes'), Tab(text: 'SMS clients')]),
        ),
        body: const TabBarView(
          children: [
            _SimpleList(items: ['Solde inhabituel - Afi', 'Retard zone Dantokpa']),
            _SimpleList(items: ['OTP cotisation - Envoye 10:42', 'PIN securite - Envoye 11:08']),
          ],
        ),
      ),
    );
  }
}

class _SimpleList extends StatelessWidget {
  const _SimpleList({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: items.map((item) => Card(child: ListTile(title: Text(item)))).toList(),
    );
  }
}
