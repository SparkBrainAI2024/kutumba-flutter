import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final String navText;
  final IconData icon;

  NavItem(this.navText, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          navText,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ]);
  }
}
