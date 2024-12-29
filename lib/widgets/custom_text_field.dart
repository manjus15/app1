// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool isPhone;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;  // Made optional with a default value
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.isPhone = false,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,  // Default to 1 line
    this.keyboardType,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType ?? (isPhone ? TextInputType.phone : TextInputType.text),
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters ?? (isPhone
              ? [FilteringTextInputFormatter.digitsOnly]
              : null),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            counter: maxLength != null ? null : const SizedBox.shrink(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}