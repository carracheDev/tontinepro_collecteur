import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/initial_avatar.dart';
import '../../../../router/app_router.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  static const clients = [
    ('c1', 'Afi Akplogan', '+2290141193597', 'eligible'),
    ('c2', 'Bio Sanni', '+2290164120988', 'retard'),
    ('c3', 'Mariam Dossa', '+2290199001234', 'tous'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            children: ['Tous', 'Eligible', 'Retard']
                .map((label) => FilterChip(label: Text(label), onSelected: (_) {}))
                .toList(),
          ),
          const SizedBox(height: 14),
          Text('Recemment visites', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) => _AvatarName(name: clients[i].$2),
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemCount: clients.length,
            ),
          ),
          const SizedBox(height: 12),
          ...clients.map(
            (c) => Card(
              child: ListTile(
                leading: InitialAvatar(name: c.$2),
                title: Text(c.$2),
                subtitle: Text('${c.$3} - ${c.$4}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.clientDetail(c.$1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarName extends StatelessWidget {
  const _AvatarName({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: Column(
        children: [
          InitialAvatar(name: name),
          const SizedBox(height: 6),
          Text(name.split(' ').first, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
