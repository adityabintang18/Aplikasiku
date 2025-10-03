import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final bool isPassword;
  final bool isPhoneNumber;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? placeholder;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.placeholder,
    this.isPhoneNumber = false,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            color: widget.enabled
                ? Colors.grey[800]
                : const Color.fromARGB(255, 255, 255, 255),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.isPassword && _obscureText,
          validator: widget.validator,
          keyboardType:
              widget.isPhoneNumber ? TextInputType.phone : TextInputType.text,
          inputFormatters: widget.isPhoneNumber
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                  PhoneNumberFormatter(),
                ]
              : null,
          style: GoogleFonts.poppins(
            color: widget.enabled ? Colors.black : Colors.grey,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            hintText: widget.placeholder,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[700],
              // fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: widget.enabled
                ? const Color(0xffffffff)
                : Colors.grey.withValues(),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.deepPurpleAccent,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: widget.enabled
                          ? Colors.deepPurpleAccent
                          : Colors.grey,
                    ),
                    onPressed: widget.enabled
                        ? () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          }
                        : null,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var finalText = '';

    for (var i = 0; i < text.length; i++) {
      if (i == 4 || i == 8) {
        finalText += '-';
      }
      finalText += text[i];
    }

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }
}
