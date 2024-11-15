import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyWdgTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? textEditingController;
  final bool isObscure;
  final IconData? iconData;
  final Function(String value)? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final String? text;
  final String? errorText;
  final VoidCallback? onPressed;
  final bool readOnly;

  const MyWdgTextField(
      {super.key,
      this.text,
      this.errorText,
      this.maxLines = 1,
      this.labelText,
      this.hintText,
      this.textEditingController,
      this.onChanged,
      this.iconData,
      this.keyboardType = TextInputType.name,
      this.isObscure = false,
      this.onPressed,
      this.readOnly = false,
      required bool enabled});

  @override
  State<MyWdgTextField> createState() => _MyWdgTextFieldState();
}

class _MyWdgTextFieldState extends State<MyWdgTextField> {
  bool isActive = false;
  bool obscure = true;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    focusNode.addListener(() {
      setState(() {
        isActive = focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.text != null)
            Text(
              widget.text!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Roboto', // Aplicando la fuente Roboto
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: widget.maxLines == 1
                      ? 60
                      : null, // Altura dinámica basada en maxLines
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(
                      color: isActive ? Colors.black : Colors.grey,
                      width: 1, // Mismo ancho de borde que en DropdownButton
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0,
                            3), // Sombra suave para dar un efecto de elevación
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    children: [
                      if (widget.iconData != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            widget.iconData,
                            size:
                                24, // Tamaño consistente con el DropdownButton
                            color: !isActive ? Colors.grey : Colors.black,
                          ),
                        ),
                      Expanded(
                        child: TextField(
                          readOnly: widget.readOnly,
                          focusNode: focusNode,
                          maxLines: widget.maxLines,
                          controller: widget.textEditingController,
                          obscureText: widget.isObscure ? obscure : false,
                          keyboardType: widget.keyboardType,
                          decoration: InputDecoration(
                            labelText: widget.labelText,
                            hintText: widget.hintText,
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.italic, // Texto en cursiva
                            ),
                            border: InputBorder.none,
                            fillColor: Colors.black,
                            hoverColor: Colors.black,
                            focusColor: Colors.black,
                          ),
                          onChanged: (value) {
                            if (widget.onChanged != null) {
                              widget.onChanged!(value);
                            }
                          },
                        ),
                      ),
                      if (widget.isObscure)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(
                              obscure
                                  ? FontAwesomeIcons.eyeSlash
                                  : FontAwesomeIcons.eye,
                              color: obscure ? Colors.black : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.errorText != null)
            Text(
              widget.errorText!,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.red,
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
