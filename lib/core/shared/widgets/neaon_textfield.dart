import 'package:flutter/services.dart';
import 'package:questra_app/imports.dart';

class NeonTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final Color glowColor;
  final double glowSpread;
  final String hintText;
  final IconData? icon;
  final Function()? onTap;
  final bool? readOnly;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const NeonTextField({
    super.key,
    this.labelText = '',
    this.controller,
    this.onChanged,
    this.glowColor = Colors.cyan,
    this.glowSpread = 4.0,
    this.hintText = '',
    this.icon,
    this.onTap,
    this.readOnly,
    this.focusNode,
    this.validator,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: .2),
            blurRadius: glowSpread * 2,
            spreadRadius: glowSpread / 2,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: .1),
            blurRadius: glowSpread * 4,
            spreadRadius: glowSpread,
          ),
        ],
      ),
      child: TextFormField(
        validator: validator,
        inputFormatters: inputFormatters,
        focusNode: focusNode,
        readOnly: readOnly ?? false,
        controller: controller,
        onChanged: onChanged,
        maxLength: maxLength,
        cursorColor: glowColor,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 16,
        ),
        onTap: onTap,
        decoration: InputDecoration(
          counter: const SizedBox(),
          suffixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(icon),
                )
              : null,
          suffixIconColor: glowColor,
          labelText: labelText,
          labelStyle: TextStyle(
            color: glowColor.withValues(alpha: .8),
          ),
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          hintStyle: TextStyle(
            fontSize: 16,
            color: Colors.white54,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: glowColor.withValues(alpha: .5),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: glowColor,
              width: 2.5,
            ),
          ),
          errorText: '',
          errorStyle: TextStyle(fontSize: 0),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.red.withValues(alpha: .5),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: glowColor.withValues(alpha: .5),
              width: 2,
            ),
          ),
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          fillColor: Colors.black.withValues(alpha: .5),
        ),
      ),
    );
  }
}
