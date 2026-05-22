import 'package:intl/intl.dart';

abstract class Formatters {
  static final _formatMonnaie = NumberFormat('#,##0', 'fr_FR');
  static final _formatDate = DateFormat('dd/MM/yyyy', 'fr_FR');
  static final _formatDateHeure = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
  static final _formatDateLongue = DateFormat("EEEE d MMMM yyyy", 'fr_FR');

  static String montant(num valeur) => '${_formatMonnaie.format(valeur)} FCFA';

  static String montantCourt(num valeur) => _formatMonnaie.format(valeur);

  static String date(DateTime d) => _formatDate.format(d);

  static String dateHeure(DateTime d) => _formatDateHeure.format(d);

  static String dateLongue(DateTime d) => _formatDateLongue.format(d);

  static String dateRelative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inHours < 1) return 'Il y a ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return date(d);
  }

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
