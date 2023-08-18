import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  const ActionButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          color: onTap != null
              ? const Color(0XFFD5CEA3)
              : const Color.fromARGB(255, 93, 66, 53),
        ),
      ),
    );
  }
}
