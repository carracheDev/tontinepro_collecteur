import 'package:intl/intl.dart';

abstract class Formatters {
  static final _formatMonnaie = NumberFormat('#,##0', 'fr_FR');

  static String montant(num valeur) => '${_formatMonnaie.format(valeur)} FCFA';

  static String telephone(String tel) {
    final clean = tel.replaceAll('+229', '').replaceAll(' ', '');
    if (clean.length == 10) {
      return '+229 ${clean.substring(0, 2)} ${clean.substring(2, 4)} ${clean.substring(4, 6)} ${clean.substring(6, 8)} ${clean.substring(8)}';
    }
    return tel;
  }

  static String initiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
