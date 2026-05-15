import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_text_styles.dart';

class UssdGuideScreen extends StatelessWidget {
  const UssdGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const codes = ['*155*1*TP384#', '*155*2*SOLDE#', '*155*3*RETRAIT#'];
    return Scaffold(
      appBar: AppBar(title: const Text('Codes USSD')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: codes
            .map(
              (code) => Card(
                child: ListTile(
                  title: Text(code, style: AppTextStyles.amount(size: 24)),
                  trailing: IconButton(
                    tooltip: 'Copier',
                    icon: const Icon(Icons.copy),
                    onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
