import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final int maxLines;
  final bool readOnly;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixText,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          style: AppTextStyles.corps,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            hintStyle: AppTextStyles.corpsSecond,
          ),
        ),
      ],
    );
  }
}

class AppPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const AppPhoneField({super.key, required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'Numéro téléphone',
      controller: controller,
      prefixText: '+229 ',
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      onChanged: onChanged,
    );
  }
}
