import 'package:flutter/material.dart';

class InitialAvatar extends StatelessWidget {
  const InitialAvatar({super.key, required this.name, this.radius = 22});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first)
        .join()
        .toUpperCase();
    final color = Colors.primaries[name.length % Colors.primaries.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.shade100,
      child: Text(
        initials.isEmpty ? 'TP' : initials,
        style: TextStyle(color: color.shade800, fontWeight: FontWeight.w800),
      ),
    );
  }
}
