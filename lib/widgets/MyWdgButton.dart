import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';

class MyWdgButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? colorFont;
  const MyWdgButton(
      {super.key,
      required this.text,
      this.onPressed,
      this.color,
      this.colorFont});

  @override
  State<MyWdgButton> createState() => _MyWdgButtonState();
}

class _MyWdgButtonState extends State<MyWdgButton> {
  @override
  Widget build(BuildContext context) {
    return Bounce(
      tapDelay: Duration.zero,
      tilt: false,
      cursor: WidgetStateMouseCursor.clickable,
      child: GestureDetector(
        onTap: () {
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          widget.color ?? const Color.fromARGB(255, 78, 78, 78),
                      border: Border.all(color: Colors.black, width: 2)),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.colorFont ?? Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
