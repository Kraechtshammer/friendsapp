import 'package:flutter/services.dart' show TextInputFormatter;

import '../common.dart';
import '../material.dart';

/// A text input (ui-style.md §5 and §6): surface fill, radius 26, thin line
/// border that turns to the text colour when focused. Multi-line inputs use
/// a smaller radius so the corners do not eat the text.
class KeptTextField extends StatelessWidget {
  const KeptTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.hasError = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final kept = context.kept;
    final radius = BorderRadius.circular(maxLines == 1 ? 26 : 22);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      style: context.text.bodyLarge,
      cursorColor: kept.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: context.text.bodyMedium,
        floatingLabelStyle: context.text.bodyMedium,
        hintStyle: context.text.bodyMedium,
        filled: true,
        fillColor: kept.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        enabledBorder: border(hasError ? context.colors.error : kept.line, 1),
        focusedBorder: border(hasError ? context.colors.error : kept.text, 1.5),
      ),
    );
  }
}
