abstract class Validators {
  static bool telephoneBenin(String digits) {
    final d = digits.replaceAll(' ', '');
    return d.length == 10 && RegExp(r'^[0-9]+$').hasMatch(d);
  }

  static bool pin(String pin) => pin.length == 4 && RegExp(r'^\d{4}$').hasMatch(pin);
}
