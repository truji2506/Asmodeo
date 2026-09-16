import 'package:flutter/material.dart';

class FragmentDraggable extends StatelessWidget {
  final String id;
  final Color color;
  final String name;
  final IconData icon;
  final bool isPlaced;

  const FragmentDraggable({
    super.key,
    required this.id,
    required this.color,
    required this.name,
    required this.icon,
    this.isPlaced = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPlaced) {
      return const SizedBox(width: 80, height: 80); // Ocultar si ya está ensamblado
    }

    final fragmentWidget = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    return Draggable<String>(
      data: id,
      feedback: Transform.scale(
        scale: 1.1,
        child: Material(
          color: Colors.transparent,
          child: fragmentWidget,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: fragmentWidget,
      ),
      child: fragmentWidget,
    );
  }
}
