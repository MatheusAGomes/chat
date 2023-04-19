import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Utils/ColorsService.dart';



class TextFieldPadrao extends StatefulWidget {
  final Key? textFormFildKey;
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardtype;
  final bool hideTextfild;
  final VoidCallback click;
  final double fontSize;
  final TextInputAction? textInputAction;
  final Function(String?)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final String? Function(String?)? onchange;
  final FocusNode? focusNode;
  final String? errorText;
  final dynamic padding;
  final int? maxlength;
  final bool? enable;
  List<TextInputFormatter>? inputFormatter;
  TextFieldPadrao({
    this.textFormFildKey,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardtype = TextInputType.text,
    this.hideTextfild = false,
    required this.click,
    this.fontSize = 14,
    this.validator,
    this.controller,
    this.onchange,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
    this.errorText,
    this.padding,
    this.maxlength,
    this.enable,
    this.inputFormatter
  });

  @override
  State<TextFieldPadrao> createState() => _TextFieldPadraoState();
}

class _TextFieldPadraoState extends State<TextFieldPadrao> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(

      inputFormatters: widget.inputFormatter,
      enabled: widget.enable,
      maxLength: widget.maxlength,
      textAlignVertical: TextAlignVertical.center,
      focusNode: widget.focusNode,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      key: widget.textFormFildKey,
      onChanged: widget.onchange,
      controller: widget.controller,
      validator: widget.validator,
      onTap: () {
        widget.click();
      },
      obscureText: widget.hideTextfild,
      keyboardType: widget.keyboardtype,
      style: TextStyle(fontSize: widget.fontSize),
      decoration: InputDecoration(
        filled: true ,
        fillColor: ColorService.cinza,
        counterText: "",
        floatingLabelAlignment: FloatingLabelAlignment.center,
        contentPadding: widget.padding,
        alignLabelWithHint: true,
        errorText: widget.errorText,
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(width: 2, color: Colors.transparent)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(width: 1, color: Colors.red)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(width: 1, color: Colors.red)),
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintStyle:  TextStyle(color: ColorService.cinzaInputLetra),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(width: 2, color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(width: 2, color: Colors.transparent)),
      ),
    );
  }
}
